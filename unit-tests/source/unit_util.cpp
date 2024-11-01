#include "himan_unit.h"
#include "util.h"
#include <cstdio>

#define BOOST_TEST_MODULE util

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;

BOOST_AUTO_TEST_CASE(CENTRAL_DIFFERENCE)
{
	// Filter a plane with given filter kernel
	// Declare matrices
	himan::matrix<double> A(5, 5, 1, MissingDouble());
	himan::matrix<double> B;
	himan::matrix<double> C;

	// Matrices containing the correct solution
	himan::matrix<double> D(5, 5, 1, MissingDouble());
	himan::matrix<double> E(5, 5, 1, MissingDouble());

	// Fill matrix A and solution matrices D and E
	for (size_t i = 0; i < A.Size(); ++i)
	{
		A.Set(i, double(i));
		D.Set(i, 1.0 / double(1 + i / 5));
		E.Set(i, 5.0);
	}

	std::pair<himan::matrix<double>, himan::matrix<double>> grad_A;

	// Declare vectors for grid spacing
	std::vector<double> dx{1.0, 2.0, 3.0, 4.0, 5.0};
	std::vector<double> dy(5, 1.0);

	grad_A = himan::util::CentralDifference(A, dx, dy, true);
	B = std::get<0>(grad_A);
	C = std::get<1>(grad_A);

	BOOST_CHECK(B == D && C == E);
}

BOOST_AUTO_TEST_CASE(MAKESQLINTERVAL)
{
	forecast_time f1("2015-01-09 00:00:00", "2015-01-09 12:00:00");

	BOOST_REQUIRE(util::MakeSQLInterval(f1) == "12:00:00");

	forecast_time f2("2015-01-09 00:00:00", "2015-01-09 00:15:00");

	BOOST_REQUIRE(util::MakeSQLInterval(f2) == "00:15:00");

	forecast_time f3("2015-01-09 00:00:00", "2015-01-19 00:16:00");

	BOOST_REQUIRE(util::MakeSQLInterval(f3) == "240:16:00");

	forecast_time f4("2015-01-09 00:00:00", "2015-10-19 00:00:00");

	BOOST_REQUIRE(util::MakeSQLInterval(f4) == "6792:00:00");

	forecast_time f5("2015-01-09 00:00:00", "2015-01-09 00:00:00");

	BOOST_REQUIRE(util::MakeSQLInterval(f5) == "00:00:00");
}

BOOST_AUTO_TEST_CASE(EXPAND)
{
	setenv("BOOST_TEST", "xyz", 1);

	string test = "$BOOST_TEST/asdf";

	string expanded = util::Expand(test);

	BOOST_REQUIRE(expanded == "xyz/asdf");

	setenv("BOOST_TEST_2", "123", 1);

	test = "$BOOST_TEST/asdf/$BOOST_TEST_2";

	expanded = util::Expand(test);

	BOOST_REQUIRE(expanded == "xyz/asdf/123");
}

BOOST_AUTO_TEST_CASE(EXPAND_STRING)
{
	std::string str = "1,3,6";
	auto splt = util::ExpandString(str);
	BOOST_REQUIRE(splt.size() == 3);
	str = "1,3-6";
	splt = util::ExpandString(str);
	BOOST_REQUIRE(splt.size() == 5);
	BOOST_REQUIRE(splt[3] == 5);
	str = "3-9-3";
	splt = util::ExpandString(str);
	BOOST_REQUIRE(splt.size() == 3);
	BOOST_REQUIRE(splt[2] == 9);
	str = "9-3-3";
	splt = util::ExpandString(str);
	BOOST_REQUIRE(splt.size() == 3);
	BOOST_REQUIRE(splt[2] == 3);
}

BOOST_AUTO_TEST_CASE(EXPAND_TIMEDURATION)
{
	std::string str = "1:00:00,3:00:00,6:00:00";
	auto splt = util::ExpandTimeDuration(str);
	BOOST_REQUIRE(splt.size() == 3);
	str = "1:00:00,3:00:00-6:00:00";
	splt = util::ExpandTimeDuration(str);
	BOOST_REQUIRE(splt.size() == 5);
	BOOST_REQUIRE(splt[3].String("%h:%02M:%02S") == "5:00:00");
	str = "3:00:00-9:00:00-3:00:00";
	splt = util::ExpandTimeDuration(str);
	BOOST_REQUIRE(splt.size() == 3);
	BOOST_REQUIRE(splt[2].String("%h:%02M:%02S") == "9:00:00");
	str = "9:00:00-3:00:00-3:00:00";
	splt = util::ExpandTimeDuration(str);
	BOOST_REQUIRE(splt.size() == 3);
	BOOST_REQUIRE(splt[2].String("%h:%02M:%02S") == "3:00:00");
	str = "0:00:00-1:00:00-0:15:00";
	splt = util::ExpandTimeDuration(str);
	BOOST_REQUIRE(splt.size() == 5);
	BOOST_REQUIRE(splt[2].String("%h:%02M:%02S") == "0:30:00");
}

BOOST_AUTO_TEST_CASE(FLIP)
{
	matrix<double> m(6, 6, 1, himan::MissingDouble());
	double j = 0;

	for (size_t i = 1; i <= m.Size(); i++)
	{
		m.Set(i - 1, j);

		if (i % m.SizeY() == 0)
			j++;
	}

	BOOST_REQUIRE(m.At(0) == 0);
	BOOST_REQUIRE(m.At(35) == 5);

	util::Flip(m);

	BOOST_REQUIRE(m.At(0) == 5);
	BOOST_REQUIRE(m.At(35) == 0);

	util::Flip(m);

	BOOST_REQUIRE(m.At(0) == 0);
	BOOST_REQUIRE(m.At(35) == 5);
}

BOOST_AUTO_TEST_CASE(FILETYPE)
{
	// generate files with magic header

	// grib
	auto fp = fopen("/tmp/grib", "wb");
	const char grib[4] = {0x47, 0x52, 0x49, 0x42};
	fwrite(grib, 1, 4, fp);
	fclose(fp);

	// nc3
	fp = fopen("/tmp/nc3", "wb");
	const char nc3[4] = {0x43, 0x44, 0x46, 0x01};
	fwrite(nc3, 1, 4, fp);
	fclose(fp);

	// nc4
	fp = fopen("/tmp/nc4", "wb");
	const unsigned char nc4[4] = {0xD3, 0x48, 0x44, 0x46};
	fwrite(nc4, 1, 4, fp);
	fclose(fp);

	// tif
	fp = fopen("/tmp/tif", "wb");
	const unsigned char tif[4] = {0x49, 0x49, 0x2A, 0x0};
	fwrite(tif, 1, 4, fp);
	fclose(fp);

	// qd
	fp = fopen("/tmp/qd", "wb");
	const unsigned char qd[9] = {0x40, 0x24, 0xb0, 0xa3, 0x51, 0x49, 0x4e, 0x46, 0x4f};
	fwrite(qd, 1, 9, fp);
	fclose(fp);

	BOOST_REQUIRE(util::FileType("/tmp/grib") == kGRIB);
	BOOST_REQUIRE(util::FileType("/tmp/nc3") == kNetCDF);
	BOOST_REQUIRE(util::FileType("/tmp/nc4") == kNetCDFv4);
	BOOST_REQUIRE(util::FileType("/tmp/tif") == kGeoTIFF);
	BOOST_REQUIRE(util::FileType("/tmp/qd") == kQueryData);

	std::remove("/tmp/grib");
	std::remove("/tmp/nc3");
	std::remove("/tmp/nc4");
	std::remove("/tmp/tif");
	std::remove("/tmp/qd");
}

BOOST_AUTO_TEST_CASE(GETSCALEDVALUE)
{
	auto s = util::GetScaledValue(100.);
	BOOST_REQUIRE(s.first == 100 && s.second == 0);

	s = util::GetScaledValue(0.);
	BOOST_REQUIRE(s.first == 0 && s.second == 0);

	s = util::GetScaledValue(74.);
	BOOST_REQUIRE(s.first == 74 && s.second == 0);

	s = util::GetScaledValue(7010);
	BOOST_REQUIRE(s.first == 701 && s.second == -1);

	s = util::GetScaledValue(500.1);
	BOOST_REQUIRE(s.first == 5001 && s.second == -1);

	s = util::GetScaledValue(5.12345);
	BOOST_REQUIRE(s.first == 512345 && s.second == -5);

	s = util::GetScaledValue(5.12345678);
	BOOST_REQUIRE(s.first == 512345678 && s.second == -8);

	s = util::GetScaledValue(5.999999999);
	BOOST_REQUIRE(s.first == 600000000 && s.second == -8);

	s = util::GetScaledValue(-13.44);
	BOOST_REQUIRE(s.first == -1344 && s.second == -2);
}

BOOST_AUTO_TEST_CASE(GETAGGREGATIONFROMPARAMNAME)
{
	std::string name;
	forecast_time ftime("2023-10-25 00:00:00", "2023-10-25 06:00:00");

	name = "RR-KGM2";
	aggregation a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == ftime.Step(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RRR-KGM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == ONE_HOUR,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RR-12-KGM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == TWELVE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "SN-3-MM";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == THREE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RRRS-KGM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == ONE_HOUR,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "PREC7D-KGM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == time_duration("168:00:00"),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "FFG-MS";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kMaximum && a.TimeDuration() == ONE_HOUR,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "FFG2-MS";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kUnknownAggregationType,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "FFG3H-MS";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kMaximum && a.TimeDuration() == THREE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "WGU-MS";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kMaximum && a.TimeDuration() == ONE_HOUR,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "TMAX3H-K";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kMaximum && a.TimeDuration() == THREE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "TMIN12H-C";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kMinimum && a.TimeDuration() == TWELVE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "TMIN-K";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kMinimum && a.TimeDuration() == ONE_HOUR,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "POTMAX24H-PRCNT";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kMaximum && a.TimeDuration() == time_duration("24:00:00"),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "MAXHGT-KM";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kUnknownAggregationType && a.TimeDuration().Empty(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "PROB-RR-4";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kUnknownAggregationType && a.TimeDuration().Empty(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "PROB-RR12-1";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == TWELVE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "PROB-CONV-RR3-3";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == THREE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "PROB-SN3-1";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == THREE_HOURS,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "UVIMAX-N";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kUnknownAggregationType,
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RADGLOCA-JM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == ftime.Step(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RTOPSWA-JM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == ftime.Step(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RNETLWA-JM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAccumulation && a.TimeDuration() == ftime.Step(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RNETLW-WM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAverage && a.TimeDuration().Empty(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());

	name = "RADGLO-WM2";
	a = util::GetAggregationFromParamName(name, ftime);
	BOOST_REQUIRE_MESSAGE(a.Type() == kAverage && a.TimeDuration().Empty(),
	                      name << " failed with aggregation type " << a.Type() << " time period " << a.TimeDuration());


}
