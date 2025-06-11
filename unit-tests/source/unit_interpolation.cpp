#include "himan_unit.h"
#include "info.h"
#include "interpolate.h"
#include "lambert_conformal_grid.h"
#include "lambert_equal_area_grid.h"
#include "stereographic_grid.h"
#include "timer.h"
#include <ogr_spatialref.h>

#define BOOST_TEST_MODULE interpolation

using namespace std;
using namespace himan;

shared_ptr<grid> CreateGrid(const std::string& name);

const double kEpsilon = 1e-2;

auto ecedit = CreateGrid("ECEDIT100");

double LatLonSum(point p)
{
	double x = p.X();
	double y = p.Y();

	if (x > 180.0)
		x -= 360;
	return x + y;
}

shared_ptr<grid> CreateGrid(const std::string& name)
{
	if (name == "HELMI")
	{
		return make_shared<latitude_longitude_grid>(kBottomLeft, point(16.716801, 56.7416), 415, 556, 0.03333, 0.01667,
		                                            earth_shape<double>(6371220.));
	}
	else if (name == "ECEDIT100")
	{
		return make_shared<rotated_latitude_longitude_grid>(kTopLeft, point(-10, 13), 201, 221, 0.1, 0.1,
		                                                    earth_shape<double>(6371220.), point(20, -30), true);
	}
	else if (name == "ECEUR0100")
	{
		return make_shared<rotated_latitude_longitude_grid>(kTopLeft, point(-26, 22.5), 661, 576, 0.1, 0.1,
		                                                    earth_shape<double>(6371220.), point(0, -30), true);
	}
	else if (name == "ECGLO0100")
	{
		return make_shared<latitude_longitude_grid>(kTopLeft, point(0, 90), 3600, 1801, 0.1, 0.1,
		                                            earth_shape<double>(6371220.));
	}
	else if (name == "RCR068")
	{
		return make_shared<rotated_latitude_longitude_grid>(kBottomLeft, point(-33.5, -24), 1030, 816, 0.068, 0.068,
		                                                    earth_shape<double>(6371220.), point(0, -30), true);
	}
	else if (name == "MEPSSCAN2500")
	{
		return make_shared<lambert_conformal_grid>(kBottomLeft, point(0.238, 51.849), 889, 949, 2500, 2500, 15, 63, 63,
		                                           earth_shape<double>(6367470.), false);
	}
	else if (name == "OPERAEUROPE")
	{
		return make_shared<lambert_equal_area_grid>(kTopLeft, point(-39.24646, 67.1384), 1900, 2200, 2000.1432,
		                                            2000.1356, 10, 52, earth_shape<double>(6371220.), false);
	}
	else if (name == "SMARTMETSMALL7500")
	{
		return make_shared<stereographic_grid>(kBottomLeft, point(5.4211, 52.6997), 255, 280, 7361.039, 7414.492, 20,
		                                       earth_shape<double>(6371220.), false);
	}
	else if (name == "ECEDIT125")
	{
		return make_shared<rotated_latitude_longitude_grid>(kTopLeft, point(-10, 13), 161, 177, 0.125, 0.125,
		                                                    earth_shape<double>(6371220.), point(20, -30), true);
	}
	else if (name == "O80")
	{
		auto g = make_shared<reduced_gaussian_grid>();
		g->EarthShape(earth_shape<double>(6371220.));
		g->N(80);
		g->NumberOfPointsAlongParallels(
		    {20,  24,  28,  32,  36,  40,  44,  48,  52,  56,  60,  64,  68,  72,  76,  80,  84,  88,  92,  96,
		     100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172, 176,
		     180, 184, 188, 192, 196, 200, 204, 208, 212, 216, 220, 224, 228, 232, 236, 240, 244, 248, 252, 256,
		     260, 264, 268, 272, 276, 280, 284, 288, 292, 296, 300, 304, 308, 312, 316, 320, 324, 328, 332, 336,
		     336, 332, 328, 324, 320, 316, 312, 308, 304, 300, 296, 292, 288, 284, 280, 276, 272, 268, 264, 260,
		     256, 252, 248, 244, 240, 236, 232, 228, 224, 220, 216, 212, 208, 204, 200, 196, 192, 188, 184, 180,
		     176, 172, 168, 164, 160, 156, 152, 148, 144, 140, 136, 132, 128, 124, 120, 116, 112, 108, 104, 100,
		     96,  92,  88,  84,  80,  76,  72,  68,  64,  60,  56,  52,  48,  44,  40,  36,  32,  28,  24,  20});
		return g;
	}

	throw runtime_error("Not supported: " + name);
}

BOOST_AUTO_TEST_CASE(LATLON)
{
	auto llg = CreateGrid("ECGLO0100");
	interpolate::area_interpolation<float> interp(*llg, *ecedit, kBiLinear);

	base<float> target;
	target.grid = ecedit;
	target.data = matrix<float>(dynamic_cast<latitude_longitude_grid&>(*ecedit).Ni(),
	                            dynamic_cast<latitude_longitude_grid&>(*ecedit).Nj(), 1, MissingFloat());

	base<float> source;
	source.grid = llg;
	source.data = matrix<float>(dynamic_cast<latitude_longitude_grid&>(*llg).Ni(),
	                            dynamic_cast<latitude_longitude_grid&>(*llg).Nj(), 1, MissingFloat());

	for (size_t i = 0; i < llg->Size(); ++i)
	{
		source.data[i] = static_cast<float>(LatLonSum(llg->LatLon(i)));
	}

	interp.Interpolate(source, target);

	for (size_t i = 0; i < ecedit->Size(); ++i)
	{
		BOOST_CHECK_CLOSE(target.data[i], LatLonSum(ecedit->LatLon(i)), kEpsilon);
	}
}

BOOST_AUTO_TEST_CASE(ROTLATLON)
{
	auto rllg = CreateGrid("ECEUR0100");
	interpolate::area_interpolation<double> interp(*rllg, *ecedit, kBiLinear);

	base<double> target;
	target.grid = ecedit;
	target.data = matrix<double>(dynamic_cast<latitude_longitude_grid&>(*ecedit).Ni(),
	                             dynamic_cast<latitude_longitude_grid&>(*ecedit).Nj(), 1, MissingDouble());

	base<double> source;
	source.grid = rllg;
	source.data = matrix<double>(dynamic_cast<rotated_latitude_longitude_grid&>(*rllg).Ni(),
	                             dynamic_cast<rotated_latitude_longitude_grid&>(*rllg).Nj(), 1, MissingDouble());

	for (size_t i = 0; i < rllg->Size(); ++i)
	{
		source.data[i] = LatLonSum(rllg->LatLon(i));
	}

	interp.Interpolate(source, target);

	for (size_t i = 0; i < ecedit->Size(); ++i)
	{
		BOOST_CHECK_CLOSE(target.data[i], LatLonSum(ecedit->LatLon(i)), kEpsilon);
	}
}

BOOST_AUTO_TEST_CASE(ROTHIRLAM)
{
	auto rllg = CreateGrid("RCR068");
	interpolate::area_interpolation<double> interp(*rllg, *ecedit, kBiLinear);

	base<double> target;
	target.grid = ecedit;
	target.data = matrix<double>(dynamic_cast<latitude_longitude_grid&>(*ecedit).Ni(),
	                             dynamic_cast<latitude_longitude_grid&>(*ecedit).Nj(), 1, MissingDouble());

	base<double> source;
	source.grid = rllg;
	source.data = matrix<double>(dynamic_cast<rotated_latitude_longitude_grid&>(*rllg).Ni(),
	                             dynamic_cast<rotated_latitude_longitude_grid&>(*rllg).Nj(), 1, MissingDouble());

	for (size_t i = 0; i < rllg->Size(); ++i)
	{
		source.data[i] = LatLonSum(rllg->LatLon(i));
	}

	interp.Interpolate(source, target);

	for (size_t i = 0; i < ecedit->Size(); ++i)
	{
		BOOST_CHECK_CLOSE(target.data[i], LatLonSum(ecedit->LatLon(i)), kEpsilon);
	}
}

BOOST_AUTO_TEST_CASE(LAMBERT_CONFORMAL_CONIC)
{
	auto lam = CreateGrid("MEPSSCAN2500");
	interpolate::area_interpolation<double> interp(*lam, *ecedit, kBiLinear);

	base<double> target;
	target.grid = ecedit;
	target.data = matrix<double>(dynamic_cast<latitude_longitude_grid&>(*ecedit).Ni(),
	                             dynamic_cast<latitude_longitude_grid&>(*ecedit).Nj(), 1, MissingDouble());

	base<double> source;
	source.grid = lam;
	source.data = matrix<double>(dynamic_cast<regular_grid&>(*lam).Ni(), dynamic_cast<regular_grid&>(*lam).Nj(), 1,
	                             MissingDouble());

	for (size_t i = 0; i < lam->Size(); ++i)
	{
		source.data[i] = LatLonSum(lam->LatLon(i));
	}

	interp.Interpolate(source, target);

	int missing = 0;
	for (size_t i = 0; i < ecedit->Size(); ++i)
	{
		if (IsMissing(target.data[i]))
		{
			++missing;
			continue;
		}
		BOOST_CHECK_CLOSE(target.data[i], LatLonSum(ecedit->LatLon(i)), kEpsilon);
	}
	cout << missing << "/" << ecedit->Size() << '\n';
}

BOOST_AUTO_TEST_CASE(LAMBERT_EQUAL_AREA)
{
	auto lam = CreateGrid("OPERAEUROPE");

	interpolate::area_interpolation<double> interp(*lam, *ecedit, kBiLinear);

	base<double> target;
	target.grid = ecedit;
	target.data = matrix<double>(dynamic_cast<latitude_longitude_grid&>(*ecedit).Ni(),
	                             dynamic_cast<latitude_longitude_grid&>(*ecedit).Nj(), 1, MissingDouble());

	base<double> source;
	source.grid = lam;
	source.data = matrix<double>(dynamic_cast<regular_grid&>(*lam).Ni(), dynamic_cast<regular_grid&>(*lam).Nj(), 1,
	                             MissingDouble());

	for (size_t i = 0; i < lam->Size(); ++i)
	{
		source.data[i] = LatLonSum(lam->LatLon(i));
	}

	interp.Interpolate(source, target);

	int missing = 0;
	for (size_t i = 0; i < ecedit->Size(); ++i)
	{
		if (IsMissing(target.data[i]))
		{
			++missing;
			continue;
		}
		BOOST_CHECK_CLOSE(target.data[i], LatLonSum(ecedit->LatLon(i)), kEpsilon);
	}
	cout << missing << "/" << ecedit->Size() << '\n';
}

BOOST_AUTO_TEST_CASE(REDUCED_GAUSSIAN)
{
	auto rgg = CreateGrid("O80");

	interpolate::area_interpolation<double> interp(*rgg, *ecedit, kBiLinear);

	base<double> target;
	target.grid = ecedit;
	target.data = matrix<double>(dynamic_cast<latitude_longitude_grid&>(*ecedit).Ni(),
	                             dynamic_cast<latitude_longitude_grid&>(*ecedit).Nj(), 1, MissingDouble());

	base<double> source;
	source.grid = rgg;
	source.data = matrix<double>(rgg->Size(), 1, 1, MissingDouble());

	for (size_t i = 0; i < rgg->Size(); ++i)
	{
		source.data[i] = LatLonSum(rgg->LatLon(i));
	}

	interp.Interpolate(source, target);

	int missing = 0;
	for (size_t i = 0; i < ecedit->Size(); ++i)
	{
		if (IsMissing(target.data[i]))
		{
			++missing;
			continue;
		}
		BOOST_CHECK_CLOSE(target.data[i], LatLonSum(ecedit->LatLon(i)), 0.1);
	}
	cout << missing << "/" << ecedit->Size() << '\n';
}

BOOST_AUTO_TEST_CASE(INTERPOLATOR_MIXED_CASE)
{
	auto llg = CreateGrid("ECGLO0100");
	interpolate::area_interpolation<float> interp(*llg, *ecedit, kBiLinear);

	auto source = make_shared<base<float>>();
	source->grid = llg;
	source->data = matrix<float>(dynamic_cast<latitude_longitude_grid&>(*llg).Ni(),
	                             dynamic_cast<latitude_longitude_grid&>(*llg).Nj(), 1, MissingFloat());

	for (size_t i = 0; i < llg->Size(); ++i)
	{
		source->data[i] = static_cast<float>(LatLonSum(llg->LatLon(i)));
	}

	auto tmpinfo = make_shared<info<float>>(forecast_type(), forecast_time(), level(), param());
	tmpinfo->Create(source);

	interpolate::InterpolateArea(ecedit.get(), tmpinfo);

	auto d_source = make_shared<base<double>>();
	d_source->grid = llg;
	d_source->data = matrix<double>(dynamic_cast<latitude_longitude_grid&>(*llg).Ni(),
	                                dynamic_cast<latitude_longitude_grid&>(*llg).Nj(), 1, MissingDouble());

	for (size_t i = 0; i < llg->Size(); ++i)
	{
		d_source->data[i] = LatLonSum(llg->LatLon(i));
	}

	auto d_tmpinfo = make_shared<info<double>>(forecast_type(), forecast_time(), level(), param());
	d_tmpinfo->Create(d_source);

	interpolate::InterpolateArea(ecedit.get(), d_tmpinfo);

	const auto vals = VEC(tmpinfo);
	const auto d_vals = VEC(d_tmpinfo);

	for (size_t i = 0; i < ecedit->Size(); ++i)
	{
		BOOST_CHECK_CLOSE(vals[i], d_vals[i], kEpsilon);
	}
}

BOOST_AUTO_TEST_CASE(ROTATION_LAMBERT_AND_BACK)
{
	auto lcc = CreateGrid("MEPSSCAN2500");
	auto ll = CreateGrid("HELMI");

	lcc->UVRelativeToGrid(true);

	matrix<float> u(1, 1, 1, himan::MissingFloat()), v(1, 1, 1, himan::MissingFloat());
	u[0] = -5.0;
	v[0] = 0.122f;

	interpolate::RotateVectorComponentsCPU<float>(lcc.get(), ll.get(), u, v);

	BOOST_CHECK_CLOSE(u[0], -4.89659, 0.001);
	BOOST_CHECK_CLOSE(v[0], -1.01896, 0.001);

	// reverse

	interpolate::RotateVectorComponentsCPU<float>(ll.get(), lcc.get(), u, v);

	BOOST_CHECK_CLOSE(u[0], -5.0, 0.001);
	BOOST_CHECK_CLOSE(v[0], 0.122f, 0.001);
}

BOOST_AUTO_TEST_CASE(ROTATION_STEREOGRAPHIC_AND_BACK)
{
	auto ps = CreateGrid("SMARTMETSMALL7500");
	auto ll = CreateGrid("HELMI");

	ps->UVRelativeToGrid(true);

	matrix<float> u(1, 1, 1, himan::MissingFloat()), v(1, 1, 1, himan::MissingFloat());
	u[0] = -5.0;
	v[0] = 0.122f;

	interpolate::RotateVectorComponentsCPU<float>(ps.get(), ll.get(), u, v);

	BOOST_CHECK_CLOSE(u[0], -4.86971, 0.001);
	BOOST_CHECK_CLOSE(v[0], -1.14049, 0.001);

	// reverse

	interpolate::RotateVectorComponentsCPU<float>(ll.get(), ps.get(), u, v);

	BOOST_CHECK_CLOSE(u[0], -5.0, 0.001);
	BOOST_CHECK_CLOSE(v[0], 0.122f, 0.001);
}

BOOST_AUTO_TEST_CASE(ROTATION_ROTLATLON_AND_BACK)
{
	auto rll = CreateGrid("ECEDIT125");
	auto ll = CreateGrid("HELMI");

	rll->UVRelativeToGrid(true);

	matrix<float> u(1, 1, 1, himan::MissingFloat()), v(1, 1, 1, himan::MissingFloat());
	u[0] = -5.0;
	v[0] = 0.122f;

	interpolate::RotateVectorComponentsCPU<float>(rll.get(), ll.get(), u, v);

	BOOST_CHECK_CLOSE(u[0], -4.51097, 0.001);
	BOOST_CHECK_CLOSE(v[0], -2.16009, 0.001);

	// reverse

	interpolate::RotateVectorComponentsCPU<float>(ll.get(), rll.get(), u, v);

	BOOST_CHECK_CLOSE(u[0], -5.0, 0.001);
	BOOST_CHECK_CLOSE(v[0], 0.122f, 0.001);
}
