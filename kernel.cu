#include <fstream>
#include <iostream>
#include <iterator>
#include <vector>
#include <string>
#include <type_traits>
#include <sstream>
#include <cuda_runtime.h>
#include <cuda.h>
#include <cusolverSp.h>
#include <cusparse.h>
#include <time.h>




using namespace std;

template <typename T> 
T* vector_insert(int n, string filename, T a);
void vector_output(int n, double * vectors, string filename);
void solve(int nnz, int  n, double tol, double* dVal,   int * dCol,   int * dRow, double* dbvec, double* dx);

int main(){

	int n, nnz;
	// initial val 
	cout << "n and nnz" << endl;

	cin >> n >> nnz;

	//csr 
	double *result = new double[n];
	  int *rowPtr = new   int[n + 1];
	  int *colidx = new   int[nnz];
	double *csrval = new double[nnz];
	double *bvec = new double[n];


	// unsign int range
	if (nnz> 4294967295)
		return 1;

	if (n>4294967295)
		cout << "warn" << endl;

	//input :::::::::input은 ascii code로 저장되어야 한다.



	string finb = "sysb.mat";
	string finROW = "rowPtr.mat";
	string finCOL = "colidx.mat";
	string finVAL = "val.mat";

	double dou = 1.0;
	  int uint = 1;

	bvec = vector_insert(n, finb, dou);
	rowPtr = vector_insert(n + 1, finROW, uint);
	colidx = vector_insert(nnz, finCOL, uint);
	csrval = vector_insert(nnz, finVAL, dou);



	//cuda alloc

	  int* dCol, *dRow;
	double* dVal, *dbvec, *dx;
	cudaError_t error;

	cudaMalloc((void**)&dx, sizeof(double)*n);
	cudaMalloc((void**)&dbvec, sizeof(double)*n);
	cudaMalloc((void**)&dCol, sizeof(int)*nnz);
	cudaMalloc((void**)&dRow, sizeof(int)*(n + 1));
	cudaMalloc((void**)&dVal, sizeof(double)*nnz);



	cudaMemcpy(dbvec, bvec, sizeof(double)*n, cudaMemcpyHostToDevice);
	cudaMemcpy(dCol, colidx, sizeof(int)*nnz, cudaMemcpyHostToDevice);
	cudaMemcpy(dRow, rowPtr, sizeof(int)*(n + 1), cudaMemcpyHostToDevice);
	cudaMemcpy(dVal, csrval, sizeof(double)*nnz, cudaMemcpyHostToDevice);

	error = cudaGetLastError();
	std::cout << "Error status after cudaMemcpy in getmemInfo: " << error << std::endl;

	//create and initialize library handles
	cusolverSpHandle_t cusolver_handle;
	cusparseHandle_t cusparse_handle;
	cusolverStatus_t cusolver_status;
	cusparseStatus_t cusparse_status;
	cusparse_status = cusparseCreate(&cusparse_handle);
	std::cout << "status cusparseCreate: " << cusparse_status << std::endl;
	cusolver_status = cusolverSpCreate(&cusolver_handle);
	std::cout << "status cusolverSpCreate: " << cusolver_status << std::endl;
	// solve
	cudaDeviceSynchronize();

	double tol = 1e-6;
	solve(nnz, n, tol, dVal, dCol, dRow, dbvec, dx);

	error = cudaGetLastError();
	std::cout << "Error status after solve(): " << error << std::endl;

	cudaDeviceSynchronize();



	// return


	cudaMemcpy(result, dx, n*sizeof(double), cudaMemcpyDeviceToHost);


	// OUTPUT

	vector_output(n, result, "x_val.txt");

	//free

	cudaFree(dCol);
	cudaFree(dRow);
	cudaFree(dx);
	cudaFree(dbvec);
	cudaFree(dVal);


	return 0;
}


//cuda function

void solve(int nnz, int  n, double tol, double* dVal,   int* dCol,   int * dRow, double* dbvec, double* dx){


	// --- prepare solving and copy to GPU:
	int reorder = 0;
	int singularity = 0;

	// create matrix descriptor
	cusparseMatDescr_t descrA;
	cusparse_status = cusparseCreateMatDescr(&descrA);
	std::cout << "status cusparse createMatDescr: " << cusparse_status << std::endl;

	cudaDeviceSynchronize();

	//solve the system
	cusolver_status = cusolverSpDcsrlsvqr(cusolver_handle, m, nnz, descrA, dcsrVal,
		dcsrRowPtr, dcsrColInd, db, tol, reorder, dx,
		&singularity);

	cudaDeviceSynchronize();
}

/// 입출력
void vector_output(int n, double * vectors, string filename){

	ofstream file(filename);
	int i = 0;
	while (i<n)
	{
		file << vectors[i];
		i++;
	}
	file.close();
}
template <typename T>
T* vector_insert(int n, string filename, T a){


	ifstream file;
	file.open(filename);

	if (!file)
	{
		cout << "file input error" << endl;
		return 1;
	}

	T *vectors = new T[n];
	int i = 0;
	while (i<n &&file){
		file << vectors[i];

		i++;

	}

	file.close();
	return vectors;
}
