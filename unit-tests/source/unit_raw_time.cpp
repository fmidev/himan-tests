#include "himan_unit.h"
#include "raw_time.h"

#define BOOST_TEST_MODULE raw_time

using namespace std;
using namespace himan;

const string time_mask("%Y-%m-%d %H:%M:%D");

BOOST_AUTO_TEST_CASE(ADJUST)
{
	raw_time r("2017-02-28 00:00:00");

	r.Adjust(kYearResolution, -1);

	BOOST_REQUIRE(r.String() == "2016-02-28 00:00:00");

	r.Adjust(kHourResolution, 12);

	BOOST_REQUIRE(r.String() == "2016-02-28 12:00:00");
}

BOOST_AUTO_TEST_CASE(NEONS_TIME)
{
	const std::string neonsTime = "201708251200";

	raw_time r(neonsTime, "%Y%m%d%H%M");

	BOOST_REQUIRE(r.String() == "2017-08-25 12:00:00");

	const std::string fmtTime = r.String("%Y%m%d%H%M");

	BOOST_REQUIRE(fmtTime == neonsTime);
}

BOOST_AUTO_TEST_CASE(SQL_TIME)
{
	const std::string SQLTime = "2017-08-25 12:00:00";

	raw_time r(SQLTime, "%Y-%m-%d %H:%M:%S");

	BOOST_REQUIRE(r.String() == "2017-08-25 12:00:00");

	const std::string fmtTime = r.String("%Y-%m-%d %H:%M:%S");

	BOOST_REQUIRE(fmtTime == SQLTime);
}

BOOST_AUTO_TEST_CASE(CUSTOM_TIME_FORMAT)
{
	const std::string time = "20170825T12:00:00";

	raw_time r(time, "%Y%m%dT%H:%M:%S");

	BOOST_REQUIRE(r.String() == "2017-08-25 12:00:00");

	const std::string fmtTime = r.String("%Y%m%dT%H:%M:%S");

	BOOST_REQUIRE(fmtTime == time);
}

#ifdef SERIALIZATION
BOOST_AUTO_TEST_CASE(RAW_TIME)
{
        himan::raw_time r("2017-04-29 07:48:15");

        std::stringstream ss(stringstream::in | stringstream::out);

        {
                cereal::JSONOutputArchive oarc(ss);
                oarc(r);
        }

        himan::raw_time newr;

        {
                cereal::JSONInputArchive iarc(ss);
                iarc(newr);
        }

        BOOST_REQUIRE(r == newr);
}
#endif
