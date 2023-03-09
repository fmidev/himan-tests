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
    himan::matrix<double> A(5,5,1,MissingDouble());
    himan::matrix<double> B;
    himan::matrix<double> C;

	// Matrices containing the correct solution
	himan::matrix<double> D(5,5,1,MissingDouble());
	himan::matrix<double> E(5,5,1,MissingDouble());

    // Fill matrix A and solution matrices D and E
    for(size_t i=0; i < A.Size(); ++i)
    {
        A.Set(i, double(i));
		D.Set(i,1.0/double(1+i/5));
		E.Set(i,5.0);
    }

	std::pair<himan::matrix<double>,himan::matrix<double>> grad_A;

	// Declare vectors for grid spacing
	std::vector<double> dx {1.0,2.0,3.0,4.0,5.0};
	std::vector<double> dy(5,1.0);

	grad_A = himan::util::CentralDifference(A,dx,dy,true);
	B = std::get<0>(grad_A);
	C = std::get<1>(grad_A);

	BOOST_CHECK(B==D && C==E);
	
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

BOOST_AUTO_TEST_CASE(FLIP)
{
	matrix<double> m(6, 6, 1, himan::MissingDouble());
        double j = 0;

        for (size_t i = 1; i <= m.Size(); i++)
        {
                m.Set(i-1, j);

                if (i % m.SizeY() == 0) j++;
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
