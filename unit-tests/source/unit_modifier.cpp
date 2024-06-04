// #define BOOST_TEST_DYN_LINK

#include "himan_unit.h"
#include "modifier.h"
#include <iomanip>
#include <iostream>

#define BOOST_TEST_MODULE modifier

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;
const size_t arr_size = 9;
const size_t level_count = 4;

vector<vector<double>> values_all;
vector<vector<double>> heights_all_meters;
vector<vector<double>> heights_all_pascals;  // hpa actually

void vdump(const vector<double>& vec)
{
	int j = 0;

	for (size_t i = 0; i < vec.size(); i++, j++)
	{
		cout << " " << vec[i];
		if (j >= 2)
		{
			cout << endl;
			j = -1;
		}
	}
}

void dump(const vector<vector<double>>& vec)
{
	for (size_t i = 0; i < level_count; i++)
	{
		cout << "=== Level: " << level_count - i << " ===" << endl;
		vdump(vec[i]);
	}
}

void dump_profile(const vector<vector<double>>& height, const vector<vector<double>>& value)
{
	for (size_t i = 0; i < height[0].size(); i++)
	{
		cout << "  " << i << endl << "h -> ";
		for (size_t j = 0; j < height.size(); j++)
		{
			cout << setfill(' ') << setw(4) << height[j][i] << " ";
		}
		cout << endl << "v -> ";
		for (size_t j = 0; j < value.size(); j++)
		{
			cout << setfill(' ') << setw(4) << value[j][i] << " ";
		}
		cout << endl;
	}
}

void init_values()
{
	// Level 4, closest to ground

	vector<double> values = {-5., 15., MissingDouble(), -8., 2., 1., -1., 5, 2.};

	values_all.push_back(values);

	// Level 3

	values = {-15., 18., 7, -18., 11., 11., -10., 6, -2.};

	values_all.push_back(values);

	// Level 2

	values = {-23., 19., MissingDouble(), -28., 16., 6., -30., 6, -1.};

	values_all.push_back(values);

	// Level 1

	values = {-26., 20., 7., -23., 16., 19., -1., MissingDouble(), -10.};

	values_all.push_back(values);

	assert(values_all.size() == 4);

	cout << "=== VALUES ===\n";
	dump(values_all);
	cout << endl;
}

void init_heights_in_pascals()
{
	// Level 4, closest to ground, in hectopascals

	vector<double> heights = {995., 1000., 991., 1023., 1023., 1025., 994., 990., 1000.};

	heights_all_pascals.push_back(heights);

	// Level 3

	heights = {920., 930, 915., 940., 1000., 1000, 901., 899., 950.};

	heights_all_pascals.push_back(heights);

	// Level 2

	heights = {850., 850, 910., MissingDouble(), 900., 920., 880., 800., 830.};

	heights_all_pascals.push_back(heights);

	// Level 1

	heights = {700., 700., 710., 730., 730., 500., 680., 600., MissingDouble()};

	heights_all_pascals.push_back(heights);

	assert(heights_all_pascals.size() == 4);

	cout << "=== HEIGHTS IN HECTOPASCALS ===\n";
	dump(heights_all_pascals);
	cout << endl;
}

void init_heights_in_meters()
{
	// Level 4, closest to ground, in meters

	vector<double> heights = {15., 13., 19., 14., 12., 31., 16., 5., 22.};

	heights_all_meters.push_back(heights);

	// Level 3

	heights = {27., 33., 29., 24., 42., 41., 29., 17., 32.};

	heights_all_meters.push_back(heights);

	// Level 2

	heights = {107., 167., 130., MissingDouble(), 152., 170., 139., 120., 151.};

	heights_all_meters.push_back(heights);

	// Level 1

	heights = {402., 280., 133., 464., 412., 661., 466., 119., MissingDouble()};

	heights_all_meters.push_back(heights);

	assert(heights_all_meters.size() == 4);

	cout << "=== HEIGHTS IN METERS ===\n";
	dump(heights_all_meters);
	cout << endl;
}

void init()
{
	if (values_all.size() > 0)
	{
		return;
	}

	init_values();
	init_heights_in_meters();
	init_heights_in_pascals();
}

BOOST_AUTO_TEST_CASE(MODIFIER_MIN)
{
	init();

	modifier_min mod;

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_REQUIRE(result[0] == -26);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[7] == 5);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MIN_PA)
{
	init();

	modifier_min mod;

	mod.HeightInMeters(false);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_REQUIRE(result[0] == -26);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[7] == 5);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MAX)
{
	init();

	modifier_max mod;

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[3] == -8);
	BOOST_REQUIRE(result[7] == 6);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MAX_LIMITED)
{
	init();

	modifier_max mod;

	vector<double> upperHeights = {400, 400, 400, 400, 400, 35, 500, 95, 28};

	vector<double> lowerHeights = {10, 10, 10, 10, 10, 32, 200, 25, 23};

	mod.UpperHeight(upperHeights);
	mod.LowerHeight(lowerHeights);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(lowerHeights);
	// vdump(upperHeights);
	// vdump(result);
	BOOST_REQUIRE(result[6] == -1);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[5] == 5);
	BOOST_REQUIRE(result[7] == 6);
	BOOST_CHECK_CLOSE(result[8], 1.6, 0.001);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MIN_LIMITED)
{
	init();

	modifier_min mod;

	vector<double> upperHeights = {400, 400, 400, 400, 400, 35, 500, 95, 140};

	vector<double> lowerHeights = {10, 10, 10, 10, 10, 32, 200, 15, 25};

	mod.UpperHeight(upperHeights);
	mod.LowerHeight(lowerHeights);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(lowerHeights);
	// vdump(upperHeights);
	// vdump(result);
	BOOST_CHECK_CLOSE(result[6], -24.590, 0.001);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[5] == 2);
	BOOST_CHECK_CLOSE(result[7], 5.8333, 0.001);
	BOOST_REQUIRE(result[8] == -2);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MAX_PA)
{
	init();

	modifier_max mod;
	mod.HeightInMeters(false);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[3] == -8);
	BOOST_REQUIRE(result[7] == 6);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MAX_PA_LIMIT)
{
	init();

	modifier_max mod;
	mod.HeightInMeters(false);

	vector<double> upperHeights = {400, 400, 400, 800, 400, 300, 500, 850, 400};

	vector<double> lowerHeights = {1000, 1000, 1000, 1015, 1000, 320, 850, 950, 1000};

	mod.UpperHeight(upperHeights);
	mod.LowerHeight(lowerHeights);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_CHECK_CLOSE(result[3], -8.9638, 0.001);
	BOOST_REQUIRE(result[7] == 6);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MAXMIN)
{
	init();

	modifier_maxmin mod;

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	//  mins
	BOOST_REQUIRE(result[0] == -26);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[7] == 5);
	// maxs
	BOOST_REQUIRE(result[arr_size + 2] == 7);
	BOOST_REQUIRE(result[arr_size + 3] == -8);
	BOOST_REQUIRE(result[arr_size + 7] == 6);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MAXMIN_PA)
{
	init();

	modifier_maxmin mod;
	mod.HeightInMeters(false);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	//  mins
	BOOST_REQUIRE(result[0] == -26);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_REQUIRE(result[7] == 5);
	// maxs
	BOOST_REQUIRE(result[arr_size + 2] == 7);
	BOOST_REQUIRE(result[arr_size + 3] == -8);
	BOOST_REQUIRE(result[arr_size + 7] == 6);
}

BOOST_AUTO_TEST_CASE(MODIFIER_SUM)
{
	init();

	modifier_sum mod;

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_REQUIRE(result[0] == -69);
	BOOST_REQUIRE(result[2] == 14);
	BOOST_REQUIRE(result[8] == -1);
}

BOOST_AUTO_TEST_CASE(MODIFIER_SUM_PA)
{
	init();

	modifier_sum mod;
	mod.HeightInMeters(false);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_REQUIRE(result[0] == -69);
	BOOST_REQUIRE(result[2] == 14);
	BOOST_REQUIRE(result[8] == -1);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MEAN)
{
	init();

	modifier_mean mod;

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_CHECK_CLOSE(result[0], -22.9134, kEpsilon);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_CHECK_CLOSE(result[8], -1.38372, kEpsilon);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MEAN_USING_CALCULATION_FINISHED)
{
	init();

	modifier_mean mod;

	for (size_t i = 0; i < level_count && !mod.CalculationFinished(); i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_CHECK_CLOSE(result[0], -22.9134, kEpsilon);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_CHECK_CLOSE(result[8], -1.38372, kEpsilon);
}

BOOST_AUTO_TEST_CASE(MODIFIER_MEAN_PA)
{
	init();

	modifier_mean mod;
	mod.HeightInMeters(false);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto result = mod.Result();

	// vdump(result);
	BOOST_CHECK_CLOSE(result[0], -19.50847, kEpsilon);
	BOOST_REQUIRE(result[2] == 7);
	BOOST_CHECK_CLOSE(result[8], -1.05882, kEpsilon);
}

BOOST_AUTO_TEST_CASE(MODIFIER_COUNT)
{
	init();

	modifier_count mod;

	vector<double> findv = {-5, 21, 7, -24, 3, 15, -3, MissingDouble(), 116};

	// vdump(findv);

	mod.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto values = mod.Result();

	// vdump(values);
	BOOST_REQUIRE(values[0] == 1);
	BOOST_REQUIRE(values[1] == 0);
	BOOST_REQUIRE(values[6] == 2);
	BOOST_REQUIRE(values[7] == 0);
}

BOOST_AUTO_TEST_CASE(MODIFIER_COUNT_PA)
{
	init();

	modifier_count mod;
	mod.HeightInMeters(false);

	vector<double> findv = {-5, 21, 7, -24, 3, 15, -3, MissingDouble(), 116};

	// vdump(findv);

	mod.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto values = mod.Result();

	// vdump(values);
	BOOST_REQUIRE(values[0] == 1);
	BOOST_REQUIRE(values[1] == 0);
	BOOST_REQUIRE(values[6] == 2);
	BOOST_REQUIRE(values[7] == 0);
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDHEIGHT)
{
	init();

	modifier_findheight mod;

	vector<double> findv = {-23, 15, 0, -20, 3, 10, -3, 0, 116};

	// vdump(findv);

	mod.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto values = mod.Result();

	// vdump(values);
	BOOST_REQUIRE(values[0] == 107);
	BOOST_REQUIRE(IsMissing(values[2]));
	BOOST_CHECK_CLOSE(values[3], 200, kEpsilon);
	BOOST_CHECK_CLOSE(values[6], 18.8888, kEpsilon);

	mod.FindNth(2);
	mod.Clear();

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	values = mod.Result();

	// vdump(values);

	BOOST_REQUIRE(IsMissing(values[0]));
	BOOST_CHECK_CLOSE(values[5], 66.8, kEpsilon);
	BOOST_CHECK_CLOSE(values[6], 443.448, kEpsilon);

	mod.FindNth(0);
	mod.Clear();

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	values = mod.Result();

	// vdump(values);

	BOOST_REQUIRE(values[0] == 107);
	BOOST_REQUIRE(IsMissing(values[2]));
	BOOST_CHECK_CLOSE(values[5], 321.077, kEpsilon);
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDHEIGHT_GT_PA)
{
	init();

	modifier_findheight_gt mod1;
	mod1.HeightInMeters(false);

	vector<double> findv = {-23, 10, 0, -20, 15, 10, -3, 0, 116};

	// vdump(findv);

	mod1.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod1.Process(values_all[i], heights_all_pascals[i]);
	}

	auto values = mod1.Result();

	// vdump(values);
	BOOST_REQUIRE(values[1] == 1000);
	BOOST_REQUIRE(values[4] == 920);
	BOOST_REQUIRE(IsMissing(values[8]));

	modifier_findheight_gt mod2;
	mod2.HeightInMeters(false);
	mod2.FindValue(findv);
	mod2.FindNth(0);  // last

	for (size_t i = 0; i < level_count; i++)
	{
		mod2.Process(values_all[i], heights_all_pascals[i]);
	}

	values = mod2.Result();

	// vdump(values);
	BOOST_REQUIRE(values[1] == 700);
	BOOST_REQUIRE(values[4] == 730);
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDHEIGHT_GT)
{
	init();

	modifier_findheight_gt mod1;

	vector<double> findv = {-23, 10, 0, -20, 15, 10, -3, 0, 116};

	// vdump(findv);

	mod1.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod1.Process(values_all[i], heights_all_meters[i]);
	}

	auto values = mod1.Result();

	// vdump(values);
	BOOST_REQUIRE(values[1] == 13);
	BOOST_REQUIRE(values[4] == 130);
	BOOST_REQUIRE(IsMissing(values[8]));

	modifier_findheight_gt mod2;
	mod2.FindValue(findv);
	mod2.FindNth(0);  // last

	for (size_t i = 0; i < level_count; i++)
	{
		mod2.Process(values_all[i], heights_all_meters[i]);
	}

	values = mod2.Result();

	// vdump(values);
	BOOST_REQUIRE(values[1] == 280);
	BOOST_CHECK_CLOSE(values[4], 412, 0.001);
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDHEIGHT_LT_PA)
{
	init();

	modifier_findheight_lt mod1;
	mod1.HeightInMeters(false);

	vector<double> findv = {-23, 10, 0, -20, 15, 10, -3, 0, 0};

	// dump_profile(heights_all_pascals, values_all);
	// vdump(findv);

	mod1.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod1.Process(values_all[i], heights_all_pascals[i]);
	}

	auto values = mod1.Result();

	// vdump(values);
	BOOST_REQUIRE(values[0] == 850);
	BOOST_REQUIRE(IsMissing(values[1]));
	BOOST_REQUIRE(values[4] == 1023);
	BOOST_CHECK_CLOSE(values[8], 975, kEpsilon);

	modifier_findheight_lt mod2;
	mod2.HeightInMeters(false);
	mod2.FindValue(findv);
	mod2.FindNth(0);  // last

	for (size_t i = 0; i < level_count; i++)
	{
		mod2.Process(values_all[i], heights_all_pascals[i]);
	}

	values = mod2.Result();

	// vdump(values);
	BOOST_REQUIRE(values[3] == 730);
}

BOOST_AUTO_TEST_CASE(MODIFIER_HIMAN_360)
{
	modifier_findheight_gt gtmod;
	gtmod.HeightInMeters(false);

	vector<vector<double>> zall, vall;
	vector<double> v = {0, 0.1, 0.6, 1.0, 1.0, 1.0, 0.5, 0.2, 0, 0};

	for (size_t i = 0; i < 10; i++)
	{
		// 1000, 900, 800, 700, 600, 500, 400, 300, 200, 100
		zall.push_back({1000 - 100 * static_cast<double>(i)});
		vall.push_back({v[i]});
	}

	vector<double> findv = {0.95};

	// dump_profile(zall, vall);
	// vdump(findv);

	gtmod.FindValue(findv);

	for (size_t i = 0; i < zall.size(); i++)
	{
		gtmod.Process(vall[i], zall[i]);
	}

	auto values = gtmod.Result();

	// vdump(values);
	BOOST_CHECK_CLOSE(values[0], 712.5, kEpsilon);

	modifier_findheight_lt ltmod;
	ltmod.HeightInMeters(false);
	ltmod.LowerHeight({values[0]});
	ltmod.UpperHeight({100});

	findv = {0.05};
	// vdump(findv);

	ltmod.FindValue(findv);

	for (size_t i = 0; i < zall.size(); i++)
	{
		ltmod.Process(vall[i], zall[i]);
	}

	values = ltmod.Result();

	// vdump(values);
	BOOST_CHECK_CLOSE(values[0], 225, kEpsilon);
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDHEIGHT_LT)
{
	init();

	modifier_findheight_lt mod1;

	vector<double> findv = {-23, 10, 0, -20, 15, 10, -3, 0, 0};
	// dump_profile(heights_all_meters, values_all);

	// vdump(findv);

	mod1.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod1.Process(values_all[i], heights_all_meters[i]);
	}

	auto values = mod1.Result();

	// vdump(values);
	BOOST_REQUIRE(IsMissing(values[1]));
	BOOST_REQUIRE(values[4] == 12);
	BOOST_REQUIRE(values[8] == 27);

	modifier_findheight_lt mod2;
	mod2.FindValue(findv);
	mod2.FindNth(0);  // last

	for (size_t i = 0; i < level_count; i++)
	{
		mod2.Process(values_all[i], heights_all_meters[i]);
	}

	values = mod2.Result();

	// vdump(values);
	BOOST_REQUIRE(values[3] == 464);
	BOOST_REQUIRE(values[4] == 152);
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDHEIGHT_PA)
{
	init();

	modifier_findheight mod;
	mod.HeightInMeters(false);

	vector<double> findv = {-23, 15, 0, -20, 3, 10, -3, 0, 116};

	// vdump(findv);

	mod.FindValue(findv);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto values = mod.Result();

	// vdump(values);
	BOOST_REQUIRE(values[0] == 850);
	BOOST_REQUIRE(IsMissing(values[2]));
	BOOST_CHECK_CLOSE(values[3], 856, kEpsilon);
	BOOST_CHECK_CLOSE(values[6], 973.33333, kEpsilon);

	mod.FindNth(2);
	mod.Clear();

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	values = mod.Result();

	// vdump(values);

	BOOST_REQUIRE(IsMissing(values[0]));
	BOOST_CHECK_CLOSE(values[5], 984, kEpsilon);
	BOOST_CHECK_CLOSE(values[6], 693.79310, kEpsilon);

	mod.FindNth(0);
	mod.Clear();

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	values = mod.Result();

	// vdump(values);

	BOOST_REQUIRE(values[0] == 850);
	BOOST_REQUIRE(IsMissing(values[2]));
	BOOST_CHECK_CLOSE(values[5], 790.76923, kEpsilon);
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDVALUE)
{
	init();

	modifier_findvalue mod;

	vector<double> findh = {
	    50, 0, 51, 52, 3, 15, 103, 0, 416,
	};

	//	vdump(findh);

	mod.FindValue(findh);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_meters[i]);
	}

	auto values = mod.Result();

	// vdump(values);
	BOOST_REQUIRE(values[0] == -17.3);
	BOOST_REQUIRE(values[1] == 15);  // clamp
	BOOST_REQUIRE(values[2] == 7);
	BOOST_REQUIRE(IsMissing(values[8]));
}

BOOST_AUTO_TEST_CASE(MODIFIER_FINDVALUE_PA)
{
	init();

	modifier_findvalue mod;
	mod.HeightInMeters(false);

	vector<double> findh = {
	    995, 1010, 700, 852, 733, 850, 690, 899, 975,
	};

	// vdump(findh);

	mod.FindValue(findh);

	for (size_t i = 0; i < level_count; i++)
	{
		mod.Process(values_all[i], heights_all_pascals[i]);
	}

	auto values = mod.Result();

	// vdump(values);
	BOOST_REQUIRE(values[0] == -5);
	BOOST_REQUIRE(values[1] == 15);  // clamp
	BOOST_CHECK_CLOSE(values[3], -20.0952, kEpsilon);
	BOOST_REQUIRE(values[8] == 0);
}
