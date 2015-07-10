#include <fstream>
#include <iostream>

#include <string.h>

#include <cuda_runtime.h>
#include <cuda.h>
#include <cusolverSp.h>
#include <cusparse.h>
#include <time.h>
#include <stdio.h>



using namespace std;

template <typename T>
T* vector_insert(int n, string filename, T a);

void vector_output(int n, double * vectors, string filename);

int main(){

	int n, nnz;
	// initial val 
	cout << "n and nnz" << endl;

	cin >> n >> nnz;

	clock_t init=clock();
	//csr 
	double *result = new double[n];
	int *rowPtr = new   int[n + 1];
	int *colidx = new   int[nnz];
	double *csrval = new double[nnz];
	double *bvec = new double[n];


	// unsign int range
	if (nnz > 4294967295)
	{
		cout << 'e';
		return 1;
	}
	if (n > 4294967295)
		printf("warn");

	//input :::::::::input은 ascii code로 저장되어야 한다.

	clock_t start=clock();
	cout << 't' << start - init << endl;

	/*string finb = "sysb.mat";
	string finROW = "rowPtr.mat";
	string finCOL = "colidx.mat";
	string finVAL = "val.mat";
*/

	string finb = "ex_b.mat";
	string finROW = "ex_row.mat";
	string finCOL = "ex_col.mat";
	string finVAL = "ex_val.mat";
	string outtxt = "ex_x_val.txt";
	double dou = 1.0;
	int uint = 1;

	


	bvec = vector_insert(n, finb, dou);
	rowPtr = vector_insert(n + 1, finROW, uint);

	colidx = vector_insert(nnz, finCOL, uint);
	csrval = vector_insert(nnz, finVAL, dou);


	clock_t insert=clock();

	cout << "insert t : " << insert - init<<endl;
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
	cout << "Error status after cudaMemcpy in getmemInfo: " << error << std::endl;


	
	clock_t cudamem=clock();
	cout << "cuda mem t : " << cudamem - insert << endl;

	//create and initialize library handles
	cusolverSpHandle_t cusolver_handle;
	cusparseHandle_t cusparse_handle;
	cusolverStatus_t cusolver_status;
	cusparseStatus_t cusparse_status;
	cusparse_status = cusparseCreate(&cusparse_handle);
	cout << "status cusparseCreate: " << cusparse_status << std::endl;
	cusolver_status = cusolverSpCreate(&cusolver_handle);
	cout << "status cusolverSpCreate: " << cusolver_status << std::endl;
	// solve
	cudaDeviceSynchronize();

	double tol = 1e-6;
	// --- prepare solving and copy to GPU:
	int reorder = 0;
	int singularity = 0;

	// create matrix descriptor
	cusparseMatDescr_t descrA;
	cusparse_status = cusparseCreateMatDescr(&descrA);
	cout << "status cusparse createMatDescr: " << cusparse_status << std::endl;

	cudaDeviceSynchronize();

	clock_t culib=clock();
	cout << "cuda lib t : " << culib - cudamem<<endl;

	//solve the system
	cusolver_status = cusolverSpDcsrlsvqr(cusolver_handle, n, nnz, descrA, dVal,
		dRow, dCol, dbvec, tol, reorder, dx,
		&singularity);

	cudaDeviceSynchronize();

	error = cudaGetLastError();
	cout << "Error status after solve(): " << error << std::endl;

	cudaDeviceSynchronize();

	clock_t solv=clock();

	cout << "solve t : "<< solv - culib << endl;
	// return


	cudaMemcpy(result, dx, n*sizeof(double), cudaMemcpyDeviceToHost);
	cout << "total cuda t : " << clock() - insert << endl;

	// OUTPUT

	vector_output(n, result, outtxt);
	vector_output(n, (double*)rowPtr, "ex_row.txt");

	clock_t output=clock();
	cout << "out t : " << output - solv << endl;


	//free mem

	cudaFree(dCol);
	cudaFree(dRow);
	cudaFree(dx);
	cudaFree(dbvec);
	cudaFree(dVal);


	return 0;
}


//cuda function



/// 입출력
void vector_output(int n, double * vectors, string filename){

	ofstream file(filename);
	int i = 0;
	while (i<n)
	{
		file << vectors[i]<<'\n';
		i++;
	}
	file.close();
}
template <typename T>
T* vector_insert(int n, string filename, T a){

	ifstream file;
	file.open( filename);

	if (!file)
	{
		cout << "file input error" << endl;

	}

	T *vectors = new T[n];
	int i = 0;
	while (i<n &&file){
		file >> vectors[i];
		i++;
	}

	file.close();
	return vectors;
}
