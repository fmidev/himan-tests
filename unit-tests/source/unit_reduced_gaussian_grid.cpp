#define BOOST_TEST_DYN_LINK

#include "himan_unit.h"
#include "reduced_gaussian_grid.h"
#include "latitude_longitude_grid.h"
#include "interpolate.h"

#define BOOST_TEST_MODULE reduced_gaussian_grid

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;

BOOST_AUTO_TEST_CASE(N)
{
	reduced_gaussian_grid rg;
	rg.N(100);

	BOOST_REQUIRE(rg.N() == 100);

}

BOOST_AUTO_TEST_CASE(EQUALITY)
{
	reduced_gaussian_grid rg1;
	rg1.N(100);

	reduced_gaussian_grid rg2;
	rg2.N(101);
	
	BOOST_REQUIRE(rg1 != rg2);

	rg2.N(100);

	BOOST_REQUIRE(rg1 == rg2);

	rg1.N(4);
	rg2.N(4);

	std::vector<int> lons({5, 10, 15, 15, 15, 15, 10, 5});
	rg1.NumberOfPointsAlongParallels(lons);
	rg2.NumberOfPointsAlongParallels(lons);

	BOOST_REQUIRE(rg1 == rg2);

	lons = std::vector<int>({5, 10, 15, 16, 16, 15, 10, 5});
	rg2.NumberOfPointsAlongParallels(lons);

	BOOST_REQUIRE(rg1 != rg2);

}

#ifdef SERIALIZATION
BOOST_AUTO_TEST_CASE(SERIALIZE)
{
        auto rgg = make_shared<reduced_gaussian_grid>();
        rgg->N(2);
        rgg->NumberOfPointsAlongParallels({1, 2, 2, 1});

        std::stringstream ss(stringstream::in | stringstream::out | stringstream::binary);

        {
                cereal::BinaryOutputArchive oarc(ss);
                oarc << rgg;
        }

        shared_ptr<reduced_gaussian_grid> newrgg;

        {
                cereal::BinaryInputArchive iarc(ss);
                iarc >> newrgg;
        }

        BOOST_REQUIRE(*rgg == *newrgg);
}
#endif
