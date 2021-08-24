#include "himan_unit.h"
#include "rotation.h"
#include "point.h"

#define BOOST_TEST_MODULE rotation

using namespace himan;

BOOST_AUTO_TEST_CASE(ROTATION)
{
	const point southPole(20, -30);

	auto fromRotLatLon = geoutil::rotation<double>().FromRotLatLon(southPole.Y() * constants::kDeg,
	                                                                 southPole.X() * constants::kDeg, 0);
	auto toRotLatLon = geoutil::rotation<double>().ToRotLatLon(southPole.Y() * constants::kDeg,
	                                                             southPole.X() * constants::kDeg, 0);

	const point latlon(-10.699201,70.645320);

        geoutil::position<double> p(latlon.Y() * constants::kDeg, latlon.X() * constants::kDeg, 0.0,
                                           earth_shape<double>(1.0));
        geoutil::rotate(p, toRotLatLon);
	const point rot(p.Lon(earth_shape<double>(1.0)) * constants::kRad, p.Lat(earth_shape<double>(1.0)) * constants::kRad);

	BOOST_CHECK_CLOSE(rot.X(),-10.,1e-5);

	p = geoutil::position<double>(rot.Y() * constants::kDeg, rot.X() * constants::kDeg, 0.0,
                                           earth_shape<double>(1.0));

	geoutil::rotate(p, fromRotLatLon);
	const point reg(p.Lon(earth_shape<double>(1.0)) * constants::kRad, p.Lat(earth_shape<double>(1.0)) * constants::kRad);

        BOOST_CHECK_CLOSE(reg.X(),-10.699201,1e-5);

	// $ invproj -f "%f" +proj=ob_tran +o_proj=longlat +lon_0=20 +o_lon_p=0 +o_lat_p=30 +a=6371220.000000 +b=6371220.000000 +no_defs +to_meter=0.0174532925199
	// -10 13
	// -10.699201	70.645320
	// $ proj -f "%f" +proj=ob_tran +o_proj=longlat +lon_0=20 +o_lon_p=0 +o_lat_p=30 +a=6371220.000000 +b=6371220.000000 +no_defs +to_meter=0.0174532925199
	// -10.6992 70.6453
	// -10.000009	12.999983
}
