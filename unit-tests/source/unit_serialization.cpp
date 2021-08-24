#include "himan_unit.h"
#include "info.h"
#include "plugin_factory.h"

#define BOOST_TEST_MODULE serialization

using namespace std;
using namespace himan::plugin;

#ifdef SERIALIZATION

#include "lambert_conformal_grid.h"
#include "latitude_longitude_grid.h"
#include "param.h"
#include "point_list.h"
#include "reduced_gaussian_grid.h"
#include "stereographic_grid.h"

BOOST_AUTO_TEST_CASE(POINT_LIST)
{
	himan::point_list pl;
	std::vector<himan::station> stations;
	stations.push_back(himan::station(1, "jeejee", 25., 60.));
	pl.Stations(stations);

	std::stringstream ss(stringstream::in | stringstream::out | stringstream::binary);

	{
		cereal::BinaryOutputArchive oarc(ss);
		oarc(pl);
	}

	himan::point_list newpl;

	{
		cereal::BinaryInputArchive iarc(ss);
		iarc(newpl);
	}

	BOOST_REQUIRE(pl == newpl);
}

BOOST_AUTO_TEST_CASE(PARAM)
{
	himan::param p("T-K");
	p.Scale(100);
	p.Base(3);

	std::stringstream ss(stringstream::in | stringstream::out);

	{
		cereal::JSONOutputArchive oarc(ss);
		oarc(p);
	}

	himan::param newp;

	{
		cereal::JSONInputArchive iarc(ss);
		iarc(newp);
	}

	BOOST_REQUIRE(p == newp);
}

BOOST_AUTO_TEST_CASE(FORECAST_TIME)
{
	himan::forecast_time f("2017-04-29 06:00:00", "2017-04-29 09:00:00");

	std::stringstream ss(stringstream::in | stringstream::out | stringstream::binary);

	{
		cereal::BinaryOutputArchive oarc(ss);
		oarc(f);
	}

	himan::forecast_time newf;

	{
		cereal::BinaryInputArchive iarc(ss);
		iarc(newf);
	}

	BOOST_REQUIRE(f == newf);
}

BOOST_AUTO_TEST_CASE(FORECAST_TYPE)
{
	himan::forecast_type f(himan::kEpsControl, 0);

	std::stringstream ss(stringstream::in | stringstream::out | stringstream::binary);

	{
		cereal::BinaryOutputArchive oarc(ss);
		oarc(f);
	}

	himan::forecast_type newf;

	{
		cereal::BinaryInputArchive iarc(ss);
		iarc(newf);
	}

	BOOST_REQUIRE(f == newf);
}

BOOST_AUTO_TEST_CASE(LEVEL)
{
	himan::level f(himan::kHeightLayer, 0, 500);

	std::stringstream ss(stringstream::in | stringstream::out | stringstream::binary);

	{
		cereal::BinaryOutputArchive oarc(ss);
		oarc(f);
	}

	himan::level newf;

	{
		cereal::BinaryInputArchive iarc(ss);
		iarc(newf);
	}

	BOOST_REQUIRE(f == newf);
}

BOOST_AUTO_TEST_CASE(PRODUCER)
{
	himan::producer f(86, 230);

	std::stringstream ss(stringstream::in | stringstream::out | stringstream::binary);

	{
		cereal::BinaryOutputArchive oarc(ss);
		oarc(f);
	}

	himan::producer newf;

	{
		cereal::BinaryInputArchive iarc(ss);
		iarc(newf);
	}

	BOOST_REQUIRE(f == newf);
}

BOOST_AUTO_TEST_CASE(STATION)
{
	himan::station f(102020, "ASDF", 25, 60);

	std::stringstream ss(stringstream::in | stringstream::out | stringstream::binary);

	{
		cereal::BinaryOutputArchive oarc(ss);
		oarc(f);
	}

	himan::station newf;

	{
		cereal::BinaryInputArchive iarc(ss);
		iarc(newf);
	}

	BOOST_REQUIRE(f == newf);
}
#else
BOOST_AUTO_TEST_CASE(DUMMY_NO_SERIALIZATION)
{
	BOOST_REQUIRE(true);
}
#endif
