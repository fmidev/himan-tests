#include "himan_unit.h"
#include "latitude_longitude_grid.h"
#include "plugin_factory.h"
#include "search_options.h"
#include <ogr_spatialref.h>

#define HIMAN_AUXILIARY_INCLUDE

#include "cache.h"

#undef HIMAN_AUXILIARY_INCLUDE

#define BOOST_TEST_MODULE cache

using namespace std;
using namespace himan;
using namespace himan::plugin;

template <typename T>
shared_ptr<info<T>> CreateInfo()
{
	logger::MainDebugState = himan::kTraceMsg;

	const size_t ni = 10, nj = 10;

	auto grid =
	    make_shared<latitude_longitude_grid>(kBottomLeft, point(20, 50), point(25, 70), ni, nj, earth_shape<double>());
	auto _info =
	    make_shared<info<T>>(forecast_type(kDeterministic), forecast_time("2014-04-04 00:00:00", "2014-04-04 01:00:00"),
	                         level(kHeight, 2, "Height"), param("TestParam", 12));

	_info->Producer(producer(230));

	auto b = make_shared<base<T>>();
	b->grid = grid;
	b->data = matrix<T>(ni, nj, 1, MissingValue<T>(), MissingValue<T>());

	for (size_t i = 1; i < ni * nj; i++)
	{
		b->data.Set(i, static_cast<T>(i));
	}

	_info->Create(b);

	return _info;
}

search_options CreateSearchOptions()
{
	param p("TestParam", 12);
	level l(kHeight, 2, "Height");
	forecast_type fty(kDeterministic);
	forecast_time ft("2014-04-04 00:00:00", "2014-04-04 01:00:00");
	producer pr(230);
	auto conf = make_shared<plugin_configuration>();
	search_options opts(ft, p, l, pr, fty, conf);

	return opts;
}

BOOST_AUTO_TEST_CASE(INSERT)
{
	auto c = dynamic_pointer_cast<plugin::cache>(plugin_factory::Instance()->Plugin("cache"));

	auto dinfo = CreateInfo<double>();

	c->Insert<double>(dinfo);

	BOOST_REQUIRE(c->Size() == 1);

	auto finfo = CreateInfo<float>();

	c->Insert<float>(finfo);

	BOOST_REQUIRE(c->Size() == 1);
}

BOOST_AUTO_TEST_CASE(GET_NO_CONVERSION)
{
	logger::MainDebugState = himan::kTraceMsg;

	auto c = dynamic_pointer_cast<plugin::cache>(plugin_factory::Instance()->Plugin("cache"));

	BOOST_REQUIRE(c->Size() == 1);

	auto opts = CreateSearchOptions();

	auto ret = c->GetInfo(opts);

	BOOST_REQUIRE(ret.size() == 1);
	BOOST_REQUIRE(ret[0]->Param().Name() == "TestParam");
	BOOST_REQUIRE(IsMissing(ret[0]->Data().At(0)));
	BOOST_REQUIRE(ret[0]->Data().At(1) == 1);
	BOOST_REQUIRE(ret[0]->Data().At(99) == 99);
}

BOOST_AUTO_TEST_CASE(GET_WITH_CONVERSION)
{
	auto c = dynamic_pointer_cast<plugin::cache>(plugin_factory::Instance()->Plugin("cache"));

	BOOST_REQUIRE(c->Size() == 1);

	auto opts = CreateSearchOptions();

	auto ret = c->GetInfo<float>(opts);

	BOOST_REQUIRE(ret.size() == 1);
	BOOST_REQUIRE(ret[0]->Param().Name() == "TestParam");
	BOOST_REQUIRE(IsMissing(ret[0]->Data().At(0)));
	BOOST_REQUIRE(ret[0]->Data().At(1) == 1);
	BOOST_REQUIRE(ret[0]->Data().At(99) == 99);
}
