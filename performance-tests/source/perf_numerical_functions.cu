#include "cuda_helper.h"
#include "himan_common.h"
#include "numerical_functions.h"
#include "timer.h"

#include "numerical_functions_helper.h"

#include <boost/test/unit_test.hpp>

#define BOOST_TEST_MODULE numerical_functions_cuda

using namespace std;
using namespace himan;

BOOST_AUTO_TEST_CASE(FILTER2DGPU_CMP_CPU_TIMING)
{
	for (auto f : vector<std::string>({"Filter2D", "Max2D"}))
	{
		for (auto h : vector<int>({3, 7, 21}))
		{
			for (auto i : vector<int>({1, 5, 10, 15, 20, 40, 50}))
			{
				// Filter a plane with given filter kernel with CUDA
				const int M = i * 100;
				const int N = i * 50;
				himan::matrix<double> A(M, N, 1, MissingDouble());  // input
				himan::matrix<double> B(h, h, 1, MissingDouble());  // convolution kernel
				himan::matrix<double> D(M, N, 1, MissingDouble());  // reference for testing

				FilterTestSetup(A, B, D);

				himan::timer CPUTimer;
				himan::timer GPUTimer;
				double* d = 0;
				cudaMalloc(&d, 1);
				cudaFree(d);
				// Compute the cpu version

				if (f == "Filter2D")
				{
					CPUTimer.Start();
					himan::matrix<double> cpuResult = numerical_functions::Filter2D(A, B, false);
					CPUTimer.Stop();
					GPUTimer.Start();
					himan::matrix<double> gpuResult = numerical_functions::Filter2D(A, B, true);
					GPUTimer.Stop();
				}
				else if (f == "Max2D")
				{
					CPUTimer.Start();
					himan::matrix<double> cpuResult = numerical_functions::Max2D(A, B, false);
					CPUTimer.Stop();
					GPUTimer.Start();
					himan::matrix<double> gpuResult = numerical_functions::Max2D(A, B, true);
					GPUTimer.Stop();
				}

				std::cout << f << " input matrix (" << A.SizeX() << "x" << A.SizeY() << ") stencil size (" << B.SizeX()
				          << "x" << B.SizeY() << ") CPU: " << CPUTimer.GetTime() << " ms"
				          << " GPU: " << GPUTimer.GetTime() << " ms" << std::endl;

				if (i > 5)
				{
					BOOST_REQUIRE(CPUTimer.GetTime() > GPUTimer.GetTime());
				}
			}
		}
	}
}
