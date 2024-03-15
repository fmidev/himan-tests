#include "himan_unit.h"
#include "plugin_configuration.h"

#include "filename.h"
#include <cstdio>
#include "info.h"

#define BOOST_TEST_MODULE filename

using namespace std;
using namespace himan;

info<double> CreateInfo()
{
	logger::MainDebugState = himan::kTraceMsg;

	//const size_t ni = 10, nj = 10;

	//auto grid = shared_ptr<latitude_longitude_grid>(CreateGrid());
	info<double> i 
	    (forecast_type(kDeterministic), forecast_time("2014-04-04 00:00:00", "2014-04-04 01:00:00"),
	                         level(kHeight, 2, "Height"), param("TestParam", 12));

	i.Producer(producer(230));

	//auto b = make_shared<base<T>>();
	//b->grid = grid;
	//b->data = matrix<T>(ni, nj, 1, MissingValue<T>(), MissingValue<T>());

	return i;
}

plugin_configuration CreateConfiguration()
{
	plugin_configuration conf;
	conf.OutputFileType(kGRIB2);

	return conf;
}

BOOST_AUTO_TEST_CASE(FILENAME)
{

	auto i = CreateInfo();
	auto conf = CreateConfiguration();

	conf.FilenameTemplate("{producer_id}.{file_type}");
	auto filename = util::filename::MakeFileName(i, conf);
	BOOST_REQUIRE(filename == "230.grib2");

	setenv("TEST", "yyyy", 1);
	conf.FilenameTemplate("{param_name}-{env:TEST}");
	filename = util::filename::MakeFileName(i, conf);
	BOOST_REQUIRE(filename == "TestParam-yyyy");

	conf.FilenameTemplate("{analysis_time:%Y}-{analysis_time:%m}-{forecast_type_name}");
	filename = util::filename::MakeFileName(i, conf);
	BOOST_REQUIRE(filename == "2014-04-det");

}
