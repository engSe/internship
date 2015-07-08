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

template <typename> vector_insert(int n,ifstream file,T a);
void vector_output(double * vectors,string filename);


using namespace std;

int main(){

// initial val 
cout<<"n and nnz"<<endl;

cin<<n<<nnz;

            //csr 
double *result=new double[n];
unsigned int *rowPtr = new unsigned int[n+1];
unsigned int *colidx = new unsigned int[nnz];
double *csrval = new double[nnz]; 
double *bvec =new double[n];


// unsign int range
if (nnz> 4294967295)
return 1;

if(n>4294967295)
cout<<"warn"<<endl;

//input :::::::::input은 ascii code로 저장되어야 한다.

ifstream finb,finROW,finCOL,finVAL;

string finb="sysb.mat";
string finROW = "rowPtr.mat";
string finCOL = "colidx.mat";
string finVAL = "val.mat";

double dou=1.0;
unsigned int uint=1;

bvec=vector_insert(n,finb,dou);
rowPtr=vector_insert(n+1,finROW,uint);
colidx=vector_insert(nnz,finCOL,uint);
csrval=vector_insert(nnz,finVAL,dou);



//cuda alloc

  unsigned int* dCol, *dRow;
	double* dVal;
  cudaError_t error;

	cudaMalloc((void**)&dCol, sizeof(int)*nnz);
	cudaMalloc((void**)&dRow, sizeof(int)*(n + 1));
	cudaMalloc((void**)&dVal, sizeof(double)*nnz);
	
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





return 0;
}


//cuda function

void solve(){
  
  
  
}

/// 입출력
void vector_output(double * vectors,string filename){
	
	ofstream file(filename);
	int i=0;
	while(vectors)
	{
		file<<vectors;
		vectors++;
	}
}
template <typename T>
T* vector_insert(int n,string filename,T a){


ifstream file;
file.open(filename);

if(!file)
{
  cout<<"file input error"<<endl;
  return 1;
}

T *vectors=new T[n];
int i=0;
while(i<n &&file   ){
file<<vectors[i];

i++;

}

fclose(file);
return vectors;
}
