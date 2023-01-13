#include "himan_unit.h"
#include "time_duration.h"

#define BOOST_TEST_MODULE time_duration

using namespace himan;

BOOST_AUTO_TEST_CASE(FORMAT)
{
	const time_duration t("36:10:05");

	BOOST_CHECK(t.String("%d") == "1");
	BOOST_CHECK(t.String("%H") == "12");
	BOOST_CHECK(t.String("%M") == "10");
	BOOST_CHECK(t.String("%S") == "5");

        BOOST_CHECK(t.String("%h") == "36");
	BOOST_CHECK(t.String("%m") == "2170");
	BOOST_CHECK(t.String("%s") == "130205");

	BOOST_CHECK(t.String("%03h") == "036");
}

BOOST_AUTO_TEST_CASE(PARSE)
{
	time_duration t;
	BOOST_CHECK(t.Empty());
	t = time_duration(kDayResolution, 1);
	BOOST_CHECK(t.Hours() == 24);
	t = time_duration(kHourResolution, 6);
	BOOST_CHECK(t.Hours() == 6);
	t = time_duration(kMinuteResolution, 15);
	BOOST_CHECK(t.Minutes() == 15);
	t = time_duration("24:00:00");
	BOOST_CHECK(t.Hours() == 24);
}

BOOST_AUTO_TEST_CASE(ARITHMETIC)
{
	time_duration t(SIX_HOURS);
	t *= 2;
	BOOST_CHECK(t.Hours() == 12);
	t /= 3;
	BOOST_CHECK(t.Hours() == 4);
	t += ONE_HOUR;
	BOOST_CHECK(t.Hours() == 5);
	t -= THREE_HOURS;
	BOOST_CHECK(t.Hours() == 2);
}
