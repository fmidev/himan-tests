#include "himan_unit.h"
#include "numerical_functions.h"

#include "numerical_functions_helper.h"

#include "timer.h"

#define BOOST_TEST_MODULE numerical_functions

using namespace std;
using namespace himan;

const double kEpsilon = 1e-3;

void Dump(const himan::matrix<double>& m)
{
	for (size_t i = 0; i < m.SizeX(); ++i)
	{
		for (size_t j = 0; j < m.SizeY(); ++j)
		{
			std::cout << m.At(i, j, 0) << " ";
		}
		std::cout << std::endl;
	}
}

BOOST_AUTO_TEST_CASE(FILTER2D)
{
	// Filter a plane with given filter kernel

	// Declare matrices
	himan::matrix<double> A(11, 8, 1, MissingDouble());
	himan::matrix<double> B(3, 3, 1, MissingDouble());
	himan::matrix<double> C;
	himan::matrix<double> D(11, 8, 1, MissingDouble());

	FilterTestSetup(A, B, D);

	// Compute smoothened matrix
	C = himan::numerical_functions::Filter2D<double>(A, B, false);

	// Compare results
	for (size_t i = 0; i < C.Size(); ++i)
	{
		BOOST_CHECK_CLOSE(C.At(i), D.At(i), kEpsilon);
	}

	// computed filtered matrix
	std::cout << "Matrix C computed with Filter2D:" << std::endl;
	Dump(C);

	std::cout << std::endl << "Matrix D as reference case for Filter2D computation:" << std::endl;
	Dump(D);
}

BOOST_AUTO_TEST_CASE(FILTER2D_LARGE)
{
	// Filter a plane with given filter kernel

	// Declare matrices
	himan::matrix<double> A(1001, 500, 1, MissingDouble());
	himan::matrix<double> B(3, 3, 1, MissingDouble());
	himan::matrix<double> D(1001, 500, 1, MissingDouble());

	FilterTestSetup(A, B, D);

	himan::timer timer;
	timer.Start();

	// Compute smoothened matrix
	himan::matrix<double> C = himan::numerical_functions::Filter2D(A, B, false);

	timer.Stop();

	// Compare results
	for (size_t i = 0; i < C.Size(); ++i)
	{
		BOOST_CHECK_CLOSE(C.At(i), D.At(i), kEpsilon);
	}

	std::cout << "Filter2D took " << timer.GetTime() << " ms " << std::endl;
}

BOOST_AUTO_TEST_CASE(PROB2D)
{
	const double M = MissingDouble();
	himan::matrix<double> A(5, 5, 1, MissingDouble());
	A.Set({1, 2, 3, 4, 5, 6, 7, 8, -9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5});

	himan::matrix<double> B(3, 3, 1, MissingDouble());
	B.Set({M, 1, M, 1, 1, 1, M, 1, M});

	const double limit = 2;

	auto result = numerical_functions::Reduce2D(
	    A, B,
	    [=](double& val1, double& val2, const double& a, const double& b) {
		    if (IsValid(a * b) && a * b == limit)
			    val1 += 1;
	    },
	    [](const double& val1, const double& val2) { return (val1 >= 1) ? 1 : 0; }, 0.0, 0.0);

	std::cout << "source" << std::endl;
	Dump(A);
	std::cout << "kernel" << std::endl;
	Dump(B);
	std::cout << "result of Prob2D()" << std::endl;
	Dump(result);
	/*
	    std::cout << "---------------------" << std::endl;
	    std::cout << "A with missing values" << std::endl;

	    A.Set({M, 2, 3, 4, 5,
	        6, M, 8, -9, 0,
	        1, M, 3, 4, 5,
	        6, M, 8, 9, 0,
	        1, 2, 3, 4, 5});

	    std::cout << "source" << std::endl;
	    Dump(A);
	    std::cout << "kernel" << std::endl;
	    Dump(B);
	    std::cout << "result of Prob2D()" << std::endl;
	    Dump(result);
	*/
}

BOOST_AUTO_TEST_CASE(MAX2D)
{
	double M = MissingDouble();
	himan::matrix<double> A(5, 5, 1, MissingDouble());
	A.Set({1, 2, 3, 4, 5, 6, 7, 8, -9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5});

	himan::matrix<double> B(3, 3, 1, MissingDouble());
	B.Set({M, 1, M, 1, 1, 1, M, 1, M});

	auto result = numerical_functions::Max2D<double>(A, B, false);

	std::cout << "source" << std::endl;
	Dump(A);
	std::cout << "kernel" << std::endl;
	Dump(B);
	std::cout << "result of Max2D()" << std::endl;
	Dump(result);

	BOOST_REQUIRE(result.At(0) == 6);
	BOOST_REQUIRE(result.At(19) == 9);

	B.Set({M, M, M, M, 1, M, M, M, M});  // should return A

	result = numerical_functions::Max2D<double>(A, B, false);

	for (size_t i = 0; i < A.Size(); ++i)
	{
		BOOST_REQUIRE(A.At(i) == result.At(i));
	}

	A.Set({-1, -2, -3, -4, -5, -6, -7, -8, -9, -0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -0, -1, -2, -3, -4, -5});

	B.Set(std::vector<double>(9, 1));

	result = numerical_functions::Max2D<double>(A, B, false);

	std::cout << "source" << std::endl;
	Dump(A);
	std::cout << "kernel" << std::endl;
	Dump(B);
	std::cout << "result of Max2D()" << std::endl;
	Dump(result);

	BOOST_REQUIRE(result.At(0) == -1);
	BOOST_REQUIRE(result.At(19) == 0);
}

BOOST_AUTO_TEST_CASE(ARANGE)
{
	std::vector<double> start({2.0, 2.1, himan::MissingDouble()});
	std::vector<double> stop({10.0, 2.4, 3});

	auto ret = numerical_functions::Arange<double>(start, stop, 2);

	BOOST_REQUIRE(ret[0].size() == 4);
	BOOST_REQUIRE(ret[1].size() == 1);
	BOOST_REQUIRE(ret[2].size() == 0);

	BOOST_REQUIRE(ret[0][0] == 2.0);
	BOOST_REQUIRE(ret[0][1] == 4.0);
	BOOST_REQUIRE(ret[0][2] == 6.0);
	BOOST_REQUIRE(ret[0][3] == 8.0);

	BOOST_REQUIRE(ret[1][0] == 2.1);
}

BOOST_AUTO_TEST_CASE(LINSPACE)
{
	std::vector<double> start({2.0, 2.1, himan::MissingDouble()});
	std::vector<double> stop({10.0, 2.4, 3});

	auto ret = numerical_functions::Linspace<double>(start, stop, 4, false);

	BOOST_REQUIRE(ret[0].size() == 4);
	BOOST_REQUIRE(ret[1].size() == 4);
	BOOST_REQUIRE(ret[2].size() == 0);

	BOOST_REQUIRE(ret[0][0] == 2.0);
	BOOST_REQUIRE(ret[0][1] == 4.0);
	BOOST_REQUIRE(ret[0][2] == 6.0);
	BOOST_REQUIRE(ret[0][3] == 8.0);

	BOOST_REQUIRE(ret[1][0] == 2.1);

	ret = numerical_functions::Linspace<double>(start, stop, 4);

	BOOST_REQUIRE(ret[0].size() == 4);
	BOOST_REQUIRE(ret[1].size() == 4);
	BOOST_REQUIRE(ret[2].size() == 0);

	BOOST_REQUIRE(ret[0][0] == 2.0);
	BOOST_CHECK_CLOSE(ret[0][1], 4.6666, 0.01);
	BOOST_CHECK_CLOSE(ret[0][2], 7.3333, 0.01);
}
