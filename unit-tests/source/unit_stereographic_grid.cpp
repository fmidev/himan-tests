#define BOOST_TEST_DYN_LINK

#include "himan_unit.h"
#include "stereographic_grid.h"
#include <ogr_spatialref.h>

#define BOOST_TEST_MODULE stereographic_grid

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;

unique_ptr<OGRSpatialReference> CreateSpatialReference()
{
	unique_ptr<OGRSpatialReference> sr = unique_ptr<OGRSpatialReference>(new OGRSpatialReference());
	sr->importFromProj4(
	    "+proj=stere +lat_0=90 +lat_ts=60 +lon_0=20 +k=1 +units=m +a=6371220.000000 +b=6371220.000000 +wktext "
	    "+no_defs");
	return move(sr);
}

stereographic_grid sg1(kBottomLeft, point(5.4211, 52.6997), 255, 280, 7361.039, 7414.492, 20,
                       earth_shape<double>(6371220));

stereographic_grid sg2(kBottomLeft, point(5.4211, 52.6997), 255, 280, 7361.039, 7414.492, CreateSpatialReference(),
                       false);

BOOST_AUTO_TEST_CASE(CONSTRUCTOR1)
{
	BOOST_REQUIRE(sg1.Ni() == 255);
	BOOST_REQUIRE(sg1.Nj() == 280);
	BOOST_REQUIRE(sg1.Orientation() == 20);
	BOOST_REQUIRE(sg1.ScanningMode() == himan::kBottomLeft);
	BOOST_REQUIRE(sg1.Class() == kRegularGrid);
	BOOST_REQUIRE(sg1.Type() == kStereographic);
	BOOST_REQUIRE(sg1.BottomLeft() == point(5.4211, 52.6997));
	BOOST_REQUIRE(sg1.BottomRight() == point(32.482230, 53.004419));

	BOOST_REQUIRE(sg1.TopLeft() == point(-9.09838, 70.1814));
	BOOST_REQUIRE(sg1.TopRight() == point(45.3471, 70.8257));
}

BOOST_AUTO_TEST_CASE(CONSTRUCTOR2)
{
	BOOST_REQUIRE(sg1 == sg2);
}

BOOST_AUTO_TEST_CASE(EQUALITY)
{
	stereographic_grid sg3(sg1);
	BOOST_REQUIRE(sg1 == sg3);
}

BOOST_AUTO_TEST_CASE(LATLON)
{
	BOOST_REQUIRE(sg1.LatLon(1) == point(5.522870, 52.715679));
}

#ifdef SERIALIZATION
BOOST_AUTO_TEST_CASE(SERIALIZE)
{
	std::stringstream ss;
	std::shared_ptr<stereographic_grid> in = std::make_shared<stereographic_grid>(sg1);

	{
		cereal::JSONOutputArchive archive(ss);
		archive(in);
	}

	std::cout << ss.str() << "\n";

	std::shared_ptr<stereographic_grid> out = nullptr;

	{
		cereal::JSONInputArchive archive(ss);
		archive(out);
	}

	BOOST_REQUIRE(sg1 == *out);
}
#endif
