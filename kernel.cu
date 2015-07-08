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


double* vector_insert(int n,ifstream file);
void vector_output(double * vectors,ofstream file);


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

//input

ifstream finb,finROW,finCOL,finVAL;

finb.open("sysb.txt");
finROW.open("rowPtr.txt");
finCOL.open("col.txt");
finVAL.open("val.txt");

if(!finb||!finROW||!finCOL||!finVAL)
{
  cout<<"file input error"<<endl;
  return 1;
}


bvec=vector_insert(n,finb);
rowPtr=vector_insert(n+1,finROW);
colidx=vector_insert(nnz,finCOL);
csrval=vector_insert(nnz,finVAL);



finb.close();
finCOL.close();
finROW.close();
finVAL.close();


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



// solve





return 0;
}


//cuda function

void solve(){
  
  
  
}

/// 입출력

template <typename T>
T* vector_insert(int n,ifstream file){

T *vectors=new T[n];
int i=0;
while(i<n &&!file.eof()   ){
file<<vectors[i];

i++;

}

return vectors;
}
