#define BOOST_TEST_DYN_LINK

#include "himan_unit.h"
#include "latitude_longitude_grid.h"
#include <ogr_spatialref.h>

#define BOOST_TEST_MODULE rotated_latitude_longitude_grid

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;
const rotated_latitude_longitude_grid lg(kBottomLeft, point(10, 40), 101, 101, 0.1, 0.1, earth_shape<double>(6371220),
                                         point(0, -40));

BOOST_AUTO_TEST_CASE(CONSTRUCTOR)
{
	BOOST_REQUIRE(lg.Ni() == 101);
	BOOST_REQUIRE(lg.Nj() == 101);
	BOOST_REQUIRE(lg.SouthPole() == point(0, -40));
	BOOST_REQUIRE(lg.UVRelativeToGrid() == false);
	BOOST_REQUIRE(lg.ScanningMode() == himan::kBottomLeft);
	BOOST_REQUIRE(lg.RotatedLatLon(0) == point(10, 40));
	BOOST_REQUIRE(lg.BottomLeft() == point(93.218731, 82.343579));
	BOOST_REQUIRE(lg.BottomRight() == point(96.466354, 74.711460));
	BOOST_REQUIRE(lg.TopLeft() == point(148.186082, 77.775930));
	BOOST_REQUIRE(lg.TopRight() == point(132.088426, 72.767827));
	BOOST_REQUIRE(lg.FirstPoint() == lg.BottomLeft());
	BOOST_REQUIRE(lg.LastPoint() == lg.TopRight());
}

BOOST_AUTO_TEST_CASE(EQUALITY)
{
	rotated_latitude_longitude_grid lg2(lg);

	BOOST_REQUIRE(lg == lg2);

	lg2.UVRelativeToGrid(true);

	BOOST_REQUIRE(lg == lg2);  // UVrelativeToGrid is not tested for equality!
}

BOOST_AUTO_TEST_CASE(ROTLATLON)
{
	auto pt = lg.LatLon(1);
	BOOST_CHECK_CLOSE(pt.X(), 93.251015, kEpsilon);
	BOOST_CHECK_CLOSE(pt.Y(), 82.26709, kEpsilon);

	pt = lg.Rotate(lg.FirstPoint());
	BOOST_CHECK_CLOSE(pt.X(), 10, kEpsilon);

	// outside grid
	pt = lg.XY(point(-10, -50));

	BOOST_REQUIRE(IsMissing(pt.X()));
	BOOST_REQUIRE(IsMissing(pt.Y()));
}

#ifdef SERIALIZATION
BOOST_AUTO_TEST_CASE(SERIALIZE)
{
	std::stringstream ss;
	std::shared_ptr<rotated_latitude_longitude_grid> in = std::make_shared<rotated_latitude_longitude_grid>(lg);

	{
		cereal::JSONOutputArchive archive(ss);
		archive(in);
	}

	std::cout << ss.str() << "\n";

	std::shared_ptr<rotated_latitude_longitude_grid> out = nullptr;

	{
		cereal::JSONInputArchive archive(ss);
		archive(out);
	}

	BOOST_REQUIRE(lg == *out);
}
#endif
