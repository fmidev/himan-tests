#include "cuda_helper.h"
#include "himan_common.h"
#include "numerical_functions.h"
#include "timer.h"

#include "numerical_functions_helper.h"

#include <boost/test/unit_test.hpp>

#define BOOST_TEST_MODULE numerical_functions_cuda

using namespace std;
using namespace himan;

const double kEpsilon = 1e-9;

const bool USE_CUDA = []() -> bool {
	int devCount;
	cudaError_t err = cudaGetDeviceCount(&devCount);
	return (err == cudaSuccess);
}();

BOOST_AUTO_TEST_CASE(FILTER2DCUDA_SMALL)
{
	if (!USE_CUDA)
	{
		std::cerr << "Cuda device not found\n";
		return;
	}

	// Filter a plane with given filter kernel with CUDA
	himan::matrix<double> A(11, 8, 1, MissingDouble());  // input
	himan::matrix<double> B(3, 3, 1, MissingDouble());   // convolution kernel
	himan::matrix<double> D(11, 8, 1, MissingDouble());  // reference for testing

	FilterTestSetup(A, B, D);

	// Compute smoothened matrix with CUDA
	auto C = numerical_functions::Reduce2DGPU(
	    A, B, [ =, *this ] __device__(double& val1, double& val2, const double& a, const double& b) {
		    if (IsValid(a * b))
		    {
			    val1 += a * b;
			    val2 += b;
		    }
	    },
	    [ =, *this ] __device__(const double& val1, const double& val2) {
		    return val2 == 0.0 ? MissingDouble() : val1 / val2;
	    },
	    0.0, 0.0);

	// Compare results
	for (size_t i = 0; i < C.Size(); ++i)
	{
		BOOST_CHECK_CLOSE(C.At(i), D.At(i), kEpsilon);
	}

	// computed filtered matrix
	std::cout << "Matrix C computed with Filter2D:" << std::endl;
	for (size_t i = 0; i < C.SizeX(); ++i)
	{
		for (size_t j = 0; j < C.SizeY(); ++j)
		{
			std::cout << C.At(i, j, 0) << " ";
		}
		std::cout << std::endl;
	}

	std::cout << std::endl << "Matrix D as reference case for Filter2D computation:" << std::endl;

	for (size_t i = 0; i < D.SizeX(); ++i)
	{
		for (size_t j = 0; j < D.SizeY(); ++j)
		{
			std::cout << D.At(i, j, 0) << " ";
		}
		std::cout << std::endl;
	}
}

// Compare against the CPU version
BOOST_AUTO_TEST_CASE(FILTER2DCUDA_LARGE_CMP_CPU)
{
	if (!USE_CUDA)
	{
		std::cerr << "Cuda device not found\n";
		return;
	}

	// Filter a plane with given filter kernel with CUDA
	himan::matrix<double> A(807, 301, 1, MissingDouble());  // input
	himan::matrix<double> B(3, 3, 1, MissingDouble());      // convolution kernel
	himan::matrix<double> D(807, 301, 1, MissingDouble());  // reference for testing

	FilterTestSetup(A, B, D);

	himan::timer CPUTimer;
	himan::timer GPUTimer;
	double* d = 0;
	cudaMalloc(&d, 1);
	cudaFree(d);
	// Compute the cpu version

	CPUTimer.Start();
	himan::matrix<double> cpuResult = numerical_functions::Filter2D<double>(A, B, false);
	CPUTimer.Stop();

	GPUTimer.Start();
	himan::matrix<double> C = numerical_functions::Filter2DGPU<double>(A, B);
	GPUTimer.Stop();

	// Compare results
	for (size_t i = 0; i < C.Size(); ++i)
	{
		BOOST_CHECK_CLOSE(C.At(i), D.At(i), kEpsilon);
	}

	for (size_t i = 0; i < C.Size(); ++i)
	{
		BOOST_CHECK_CLOSE(C.At(i), cpuResult.At(i), kEpsilon);
	}

	std::cout << "Filter2D(CPU) time for input matrix (" << A.SizeX() << "x" << A.SizeY() << "): " << CPUTimer.GetTime()
	          << " ms" << std::endl;
	std::cout << "Filter2D(GPU) time for input matrix (" << A.SizeX() << "x" << A.SizeY() << "): " << GPUTimer.GetTime()
	          << " ms" << std::endl;
}
