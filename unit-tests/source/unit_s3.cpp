#include "himan_unit.h"
#include "s3.h"

#define BOOST_TEST_MODULE s3

using namespace himan;

BOOST_AUTO_TEST_CASE(EXISTS)
{
	BOOST_CHECK(unsetenv("S3_ACCESS_KEY_ID") == 0);
	BOOST_CHECK(unsetenv("S3_SECRET_ACCESS_KEY") == 0);
	BOOST_CHECK(setenv("S3_HOSTNAME", "https://lake.fmi.fi", 1) == 0);
	BOOST_CHECK(s3::Exists("himan-tests-source-data/non-existent-object") == false);
	BOOST_CHECK(s3::Exists("himan-tests-source-data/CB-TCU_cloud_source_ec.grib"));
}
