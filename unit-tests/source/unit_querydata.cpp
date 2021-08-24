#include "himan_unit.h"
#include "latitude_longitude_grid.h"
#include "plugin_factory.h"
#include <ogr_spatialref.h>

#define HIMAN_AUXILIARY_INCLUDE

#include "querydata.h"

#undef HIMAN_AUXILIARY_INCLUDE

#define BOOST_TEST_MODULE querydata

using namespace std;
using namespace himan;

BOOST_AUTO_TEST_CASE(QUERYDATA)
{
	// Create himan::info, convert it to querydata, convert it back to info and compare results

	const size_t ni = 10, nj = 20;

	// Create info
	auto newGrid =
	    make_shared<latitude_longitude_grid>(kBottomLeft, point(20, 50), point(25, 70), ni, nj, earth_shape<double>(6371220));
	auto newInfo = info<double>(forecast_type(kDeterministic), forecast_time("2014-04-04 00:00:00", "2014-04-04 01:00:00"), level(kHeight, 2, "Height"), param("TestParam", 12));

	newInfo.Producer(producer(230, 86, 203, "TEST"));

	auto b = make_shared<base<double>>();
	b->grid = newGrid;
	b->data = matrix<double>(ni, nj, 1, 32700.0);

	for (size_t i = 0; i < ni * nj; i++)
	{
		b->data.Set(i, static_cast<double>(i + 1));
	}

	newInfo.Create(b);

	// Convert info to querydata

	auto q = dynamic_pointer_cast<plugin::querydata>(plugin_factory::Instance()->Plugin("querydata"));

	auto qdata = q->CreateQueryData(newInfo, false);

	BOOST_REQUIRE(qdata);

	// Convect querydata back to info

	auto convertInfo = q->CreateInfo<double>(qdata);

	BOOST_REQUIRE(*newInfo.Grid() == *convertInfo->Grid());
}
