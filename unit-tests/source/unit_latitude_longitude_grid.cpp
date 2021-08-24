#define BOOST_TEST_DYN_LINK

#include "himan_unit.h"
#include "latitude_longitude_grid.h"
#include <ogr_geometry.h>
#include <ogr_spatialref.h>

#define BOOST_TEST_MODULE latitude_longitude_grid

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;
latitude_longitude_grid lg(kTopLeft, point(0, 60), 101, 101, 0.1, 0.1, earth_shape<double>(6371220));

BOOST_AUTO_TEST_CASE(CONSTRUCTOR)
{
	BOOST_REQUIRE(lg.Ni() == 101);
	BOOST_REQUIRE(lg.Nj() == 101);
	BOOST_REQUIRE(lg.ScanningMode() == himan::kTopLeft);
	BOOST_REQUIRE(lg.Type() == kLatitudeLongitude);
	BOOST_REQUIRE(lg.Class() == kRegularGrid);
	BOOST_REQUIRE(lg.TopLeft() == point(0, 60));
	BOOST_REQUIRE(lg.BottomLeft() == point(0, 50));
	BOOST_REQUIRE(lg.TopRight() == point(10, 60));
	BOOST_REQUIRE(lg.BottomRight() == point(10, 50));
	BOOST_REQUIRE(lg.FirstPoint() == point(0, 60));
	BOOST_REQUIRE(lg.LastPoint() == point(10, 50));
	BOOST_REQUIRE(lg.Proj4String() == "+proj=longlat +R=6371220 +no_defs");
}

BOOST_AUTO_TEST_CASE(EQUALITY)
{
	latitude_longitude_grid lg2(lg);
	BOOST_REQUIRE(lg == lg2);
}

BOOST_AUTO_TEST_CASE(LATLON)
{
	BOOST_REQUIRE(lg.LatLon(0) == point(0, 60));
	BOOST_REQUIRE(lg.LatLon(1) == point(0.1, 60));
}

BOOST_AUTO_TEST_CASE(GEOMETRY)
{
	latitude_longitude_grid a(kBottomLeft, point(10, 10), point(14, 12), 5, 3, earth_shape<double>(6371220));
	auto g1 = a.Geometry();

	BOOST_REQUIRE(g1->IsValid());
	BOOST_REQUIRE(g1->get_Area() == 8);

	latitude_longitude_grid b(kBottomLeft, point(8, 8), point(16, 14), 9, 7, earth_shape<double>(6371220));
	auto g2 = b.Geometry();

	BOOST_REQUIRE(g2->IsValid());
	BOOST_REQUIRE(g2->get_Area() == 48);
	BOOST_REQUIRE(g2->Contains(g1.get()));

	latitude_longitude_grid c(kTopLeft, point(10, 10), point(14, 12), 5, 3, earth_shape<double>(6371220));
	auto g3 = c.Geometry();

	BOOST_REQUIRE(g3->IsValid());
	BOOST_REQUIRE(g3->get_Area() == 8);
}

#ifdef SERIALIZATION
BOOST_AUTO_TEST_CASE(SERIALIZE)
{
	std::stringstream ss;
	std::shared_ptr<latitude_longitude_grid> in = std::make_shared<latitude_longitude_grid>(lg);

	{
		cereal::JSONOutputArchive archive(ss);
		archive(in);
	}

	std::cout << ss.str() << "\n";

	std::shared_ptr<latitude_longitude_grid> out = nullptr;

	{
		cereal::JSONInputArchive archive(ss);
		archive(out);
	}

	BOOST_REQUIRE(lg == *out);
}
#endif
