#define BOOST_TEST_DYN_LINK

#include "himan_unit.h"
#include "lambert_conformal_grid.h"
#include <ogr_spatialref.h>

#define BOOST_TEST_MODULE lambert_conformal_grid

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;
const lambert_conformal_grid sg(kBottomLeft, point(10, 50), 25, 25, 2500, 2500, 20, 50, 50,
                      earth_shape<double>(6371220));

BOOST_AUTO_TEST_CASE(CONSTRUCTOR)
{
	BOOST_REQUIRE(sg.Ni() == 25);
	BOOST_REQUIRE(sg.Nj() == 25);
	BOOST_REQUIRE(sg.Orientation() == 20);
	BOOST_REQUIRE(sg.ScanningMode() == kBottomLeft);
	BOOST_REQUIRE(sg.Class() == kRegularGrid);
	BOOST_REQUIRE(sg.Type() == kLambertConformalConic);
	BOOST_REQUIRE(sg.BottomLeft() == point(10., 50.));
	BOOST_REQUIRE(sg.BottomRight() == point(10.833149, 50.068948));
	BOOST_REQUIRE(sg.TopLeft() == point(9.886844, 50.534697));
	BOOST_REQUIRE(sg.TopRight() == point(10.729219, 50.604418));
}

BOOST_AUTO_TEST_CASE(EQUALITY)
{
	lambert_conformal_grid sg1(sg);
	BOOST_REQUIRE(sg1 == sg);
}

BOOST_AUTO_TEST_CASE(LATLON)
{
	BOOST_REQUIRE(sg.LatLon(1) == point(10.034666,50.002992));
}

#ifdef SERIALIZATION
BOOST_AUTO_TEST_CASE(SERIALIZE)
{
        std::stringstream ss;
        std::shared_ptr<lambert_conformal_grid> in = std::make_shared<lambert_conformal_grid> (sg);

        {
                cereal::JSONOutputArchive archive(ss);
                archive(in);
        }

        std::cout << ss.str() << "\n";

        std::shared_ptr<lambert_conformal_grid> out = nullptr;

        {
                cereal::JSONInputArchive archive(ss);
                archive(out);
        }


        BOOST_REQUIRE(sg == *out);
}
#endif
