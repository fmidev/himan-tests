#define BOOST_TEST_DYN_LINK

#include "himan_unit.h"
#include "transverse_mercator_grid.h"
#include <ogr_spatialref.h>

#define BOOST_TEST_MODULE transverse_mercator_grid

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;
const transverse_mercator_grid sg(kTopLeft, point(9, 50), 10, 10, 1000, 1000, 9, 0, 1, 3500000, 0,
                                  earth_shape<double>(6377397.155,
                                                      6356078.963));  // Gauss-Kruger on Germany area (aka EPSG:31467)

BOOST_AUTO_TEST_CASE(CONSTRUCTOR)
{
	BOOST_REQUIRE(sg.Ni() == 10);
	BOOST_REQUIRE(sg.Nj() == 10);
	BOOST_REQUIRE(sg.Orientation() == 9);
	BOOST_REQUIRE(sg.ScanningMode() == kTopLeft);
	BOOST_REQUIRE(sg.Class() == kRegularGrid);
	BOOST_REQUIRE(sg.Type() == kTransverseMercator);
	BOOST_REQUIRE(sg.TopLeft() == point(9, 50.));
	BOOST_REQUIRE(sg.BottomLeft() == point(9., 49.919076));
	BOOST_REQUIRE(sg.TopRight() == point(9.125546, 49.999932));
	BOOST_REQUIRE(sg.BottomRight() == point(9.125335, 49.919008));
	BOOST_REQUIRE(sg.FirstPoint() == sg.TopLeft());
	BOOST_REQUIRE(sg.LastPoint() == sg.BottomRight());
}

BOOST_AUTO_TEST_CASE(EQUALITY)
{
	transverse_mercator_grid sg1(sg);
	BOOST_REQUIRE(sg1 == sg);
}

BOOST_AUTO_TEST_CASE(LATLON)
{
	BOOST_REQUIRE(sg.LatLon(1) == point(9.013950, 49.999999));
}

#ifdef SERIALIZATION
BOOST_AUTO_TEST_CASE(SERIALIZE)
{
	std::stringstream ss;
	std::shared_ptr<transverse_mercator_grid> in = std::make_shared<transverse_mercator_grid>(sg);

	{
		cereal::JSONOutputArchive archive(ss);
		archive(in);
	}

	std::cout << ss.str() << "\n";

	std::shared_ptr<transverse_mercator_grid> out = nullptr;

	{
		cereal::JSONInputArchive archive(ss);
		archive(out);
	}

	BOOST_REQUIRE(sg == *out);
}
#endif
