#include "himan_unit.h"
#include "probability_impl.h"
#include <random>

#define BOOST_TEST_MODULE probability

using namespace std;
using namespace himan;
using namespace PROB;

const float kMissing = MissingFloat();

namespace
{
// Rule that is fulfilled if value is greater than limit
PROB::rule_input GreaterThan(const vector<float>& values, float limit, bool allowMissing = false)
{
	return PROB::rule_input{values, [limit](float x) { return x > limit; }, allowMissing};
}

// Rule that is fulfilled if value is equal to limit
PROB::rule_input Equals(const vector<float>& values, float limit, bool allowMissing = false)
{
	return PROB::rule_input{values, [limit](float x) { return x == limit; }, allowMissing};
}

vector<float> Repeat(float value, size_t count)
{
	return vector<float>(count, value);
}

// Concatenate vectors
vector<float> Cat(vector<float> a, const vector<float>& b)
{
	a.insert(a.end(), b.begin(), b.end());
	return a;
}
}  // namespace

BOOST_AUTO_TEST_CASE(PREDICATE_SINGLE_VALUE_OPERATORS)
{
	const auto lt = MakePredicate(kProbabilityLessThan, "2");
	BOOST_CHECK(lt(1.9f));
	BOOST_CHECK(!lt(2.0f));
	BOOST_CHECK(!lt(2.1f));

	const auto le = MakePredicate(kProbabilityLessThanOrEqual, "2");
	BOOST_CHECK(le(1.9f));
	BOOST_CHECK(le(2.0f));
	BOOST_CHECK(!le(2.1f));

	const auto gt = MakePredicate(kProbabilityGreaterThan, "0.04");
	BOOST_CHECK(!gt(0.03f));
	BOOST_CHECK(!gt(0.04f));  // limit is parsed with the same precision as the data
	BOOST_CHECK(gt(0.05f));

	const auto ge = MakePredicate(kProbabilityGreaterThanOrEqual, "2");
	BOOST_CHECK(!ge(1.9f));
	BOOST_CHECK(ge(2.0f));
	BOOST_CHECK(ge(2.1f));

	const auto eq = MakePredicate(kProbabilityEquals, "1");
	BOOST_CHECK(eq(1.0f));
	BOOST_CHECK(!eq(2.0f));

	const auto ne = MakePredicate(kProbabilityNotEquals, "1");
	BOOST_CHECK(!ne(1.0f));
	BOOST_CHECK(ne(2.0f));
}

BOOST_AUTO_TEST_CASE(PREDICATE_SET)
{
	const auto in = MakePredicate(kProbabilityEqualsIn, "4,5");
	BOOST_CHECK(in(4.0f));
	BOOST_CHECK(in(5.0f));
	BOOST_CHECK(!in(1.0f));
	BOOST_CHECK(!in(4.5f));
}

BOOST_AUTO_TEST_CASE(PREDICATE_RANGE)
{
	// lower endpoint is included, upper is not
	const auto between = MakePredicate(kProbabilityBetween, "5,20");
	BOOST_CHECK(!between(4.9f));
	BOOST_CHECK(between(5.0f));
	BOOST_CHECK(between(19.9f));
	BOOST_CHECK(!between(20.0f));

	BOOST_CHECK_THROW(MakePredicate(kProbabilityBetween, "5"), std::runtime_error);
	BOOST_CHECK_THROW(MakePredicate(kProbabilityBetween, "5,10,15"), std::runtime_error);
}

BOOST_AUTO_TEST_CASE(PREDICATE_INVALID)
{
	BOOST_CHECK_THROW(MakePredicate(kUnknownProcessingType, "1"), std::runtime_error);
}

BOOST_AUTO_TEST_CASE(JOINT_ALL_MEMBERS_FULFILL)
{
	// precipitation form 1 and rate > 0.04 in all members
	const auto p = JointProbability({GreaterThan(Repeat(0.10f, 10), 0.04f), Equals(Repeat(1, 10), 1, true)});
	BOOST_CHECK_EQUAL(p, 1.f);
}

BOOST_AUTO_TEST_CASE(JOINT_NO_MEMBERS_FULFILL)
{
	const auto p = JointProbability({GreaterThan(Repeat(0.f, 10), 0.04f), Equals(Repeat(0, 10), 1, true)});
	BOOST_CHECK_EQUAL(p, 0.f);
}

BOOST_AUTO_TEST_CASE(JOINT_IS_NOT_PRODUCT_OF_SINGLE_PROBABILITIES)
{
	// members 0-2 fulfill both, 3-5 only the first, 6-8 only the second, 9 neither
	const vector<float> rate = {0.10f, 0.10f, 0.10f, 0.01f, 0.01f, 0.01f, 0.10f, 0.10f, 0.10f, 0.f};
	const vector<float> form = {1, 1, 1, 1, 1, 1, 0, 0, 0, 0};

	const auto rateOnly = JointProbability({GreaterThan(rate, 0.04f)});
	const auto formOnly = JointProbability({Equals(form, 1, true)});
	const auto both = JointProbability({GreaterThan(rate, 0.04f), Equals(form, 1, true)});

	BOOST_CHECK_CLOSE(rateOnly, 0.6f, 1e-4);
	BOOST_CHECK_CLOSE(formOnly, 0.6f, 1e-4);
	BOOST_CHECK_CLOSE(both, 0.3f, 1e-4);  // product of the single probabilities would be 0.36
}

BOOST_AUTO_TEST_CASE(JOINT_COMPARISON_IS_STRICT)
{
	// exactly the limit does not fulfill '>'
	const auto rate = Cat(Repeat(0.04f, 5), Repeat(0.05f, 5));
	const auto p = JointProbability({GreaterThan(rate, 0.04f), Equals(Repeat(1, 10), 1, true)});
	BOOST_CHECK_EQUAL(p, 0.5f);
}

BOOST_AUTO_TEST_CASE(JOINT_MISSING_IN_ALLOW_MISSING_PARAMETER)
{
	// missing precipitation form counts as 'not fulfilled' but the member stays in the denominator
	const auto form = Cat(Repeat(kMissing, 2), Repeat(1, 8));
	const auto p = JointProbability({GreaterThan(Repeat(0.10f, 10), 0.04f), Equals(form, 1, true)});
	BOOST_CHECK_CLOSE(p, 0.8f, 1e-4);
}

BOOST_AUTO_TEST_CASE(JOINT_MISSING_IN_ALLOW_MISSING_PARAMETER_ONLY)
{
	// all members missing in an allow-missing parameter means no member fulfills the rule
	const auto p = JointProbability({GreaterThan(Repeat(0.10f, 10), 0.04f), Equals(Repeat(kMissing, 10), 1, true)});
	BOOST_CHECK_EQUAL(p, 0.f);
}

BOOST_AUTO_TEST_CASE(JOINT_MISSING_IN_OTHER_PARAMETER)
{
	// member with a missing rate is left out of the calculation: 8 of 8 fulfill the rules
	const auto rate = Cat(Repeat(kMissing, 2), Repeat(0.10f, 8));
	const auto p = JointProbability({GreaterThan(rate, 0.04f), Equals(Repeat(1, 10), 1, true)});
	BOOST_CHECK_EQUAL(p, 1.f);
}

BOOST_AUTO_TEST_CASE(JOINT_MISSING_IN_OTHER_PARAMETER_IS_LEFT_OUT_FOR_EVERY_RULE)
{
	// members 0-1 have a missing rate and would also fail the form rule. They are left out of the sample
	// because of the missing rate, so the probability is 8/8 and not 8/10.
	const auto rate = Cat(Repeat(kMissing, 2), Repeat(0.10f, 8));
	const auto form = Cat(Repeat(0, 2), Repeat(1, 8));
	const auto p = JointProbability({Equals(form, 1, true), GreaterThan(rate, 0.04f)});
	BOOST_CHECK_EQUAL(p, 1.f);
}

BOOST_AUTO_TEST_CASE(JOINT_ALL_MISSING_IN_OTHER_PARAMETER)
{
	const auto p = JointProbability({GreaterThan(Repeat(kMissing, 10), 0.04f), Equals(Repeat(1, 10), 1, true)});
	BOOST_CHECK(IsMissing(p));
}

BOOST_AUTO_TEST_CASE(JOINT_NO_MEMBERS)
{
	const auto p = JointProbability({GreaterThan({}, 0.04f), Equals({}, 1, true)});
	BOOST_CHECK(IsMissing(p));
}

BOOST_AUTO_TEST_CASE(JOINT_SINGLE_RULE_IS_FRACTION_OF_MEMBERS)
{
	const vector<float> values = {1, 2, 3, 4, 5, 6, 7, 8};
	BOOST_CHECK_EQUAL(JointProbability({GreaterThan(values, 6.f)}), 0.25f);
}

BOOST_AUTO_TEST_CASE(JOINT_INVALID_INPUT)
{
	// no rules
	BOOST_CHECK_THROW(JointProbability({}), std::invalid_argument);

	// all rules must have the same number of members
	BOOST_CHECK_THROW(JointProbability({GreaterThan(Repeat(1, 10), 0.f), GreaterThan(Repeat(1, 9), 0.f)}),
	                  std::invalid_argument);
}

BOOST_AUTO_TEST_CASE(JOINT_ORDER_OF_RULES_DOES_NOT_MATTER)
{
	mt19937 gen(42);
	uniform_real_distribution<float> dist(0.f, 1.f);

	for (int round = 0; round < 200; round++)
	{
		vector<float> a(30), b(30), c(30);

		for (size_t i = 0; i < a.size(); i++)
		{
			a[i] = dist(gen) < 0.1f ? kMissing : dist(gen);
			b[i] = dist(gen) < 0.1f ? kMissing : dist(gen);
			c[i] = dist(gen) < 0.1f ? kMissing : dist(gen);
		}

		const auto ra = GreaterThan(a, 0.3f, false);
		const auto rb = GreaterThan(b, 0.5f, true);
		const auto rc = GreaterThan(c, 0.7f, false);

		const auto p1 = JointProbability({ra, rb, rc});
		const auto p2 = JointProbability({rc, ra, rb});
		const auto p3 = JointProbability({rb, rc, ra});

		BOOST_CHECK_EQUAL(IsMissing(p1), IsMissing(p2));
		BOOST_CHECK_EQUAL(IsMissing(p1), IsMissing(p3));

		if (!IsMissing(p1))
		{
			BOOST_CHECK_EQUAL(p1, p2);
			BOOST_CHECK_EQUAL(p1, p3);
		}
	}
}

BOOST_AUTO_TEST_CASE(JOINT_NEVER_EXCEEDS_SINGLE_RULE_PROBABILITY)
{
	mt19937 gen(7);
	uniform_real_distribution<float> dist(0.f, 1.f);

	for (int round = 0; round < 200; round++)
	{
		vector<float> a(30), b(30);

		for (size_t i = 0; i < a.size(); i++)
		{
			a[i] = dist(gen);
			b[i] = dist(gen);
		}

		// no missing values: the denominator is the same
		const auto both = JointProbability({GreaterThan(a, 0.3f), GreaterThan(b, 0.5f)});
		BOOST_CHECK_LE(both, JointProbability({GreaterThan(a, 0.3f)}));
		BOOST_CHECK_LE(both, JointProbability({GreaterThan(b, 0.5f)}));
	}
}

BOOST_AUTO_TEST_CASE(ALLOW_MISSING_VALUES)
{
	BOOST_CHECK(AllowMissingValuesInEnsemble("PRECFORM2-N"));
	BOOST_CHECK(AllowMissingValuesInEnsemble("PRECFORM-N"));
	BOOST_CHECK(!AllowMissingValuesInEnsemble("RRR-KGM2"));
	BOOST_CHECK(!AllowMissingValuesInEnsemble("T-K"));
}
