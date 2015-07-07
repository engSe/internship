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


double* vector_insert(int n,File *file);
void vector_output(double * vectors,File *file);
using namespace std;

int main(){

// initial val 
cout<<"n and nnz"<<endl;

cin<<n<<nnz;


double *result=new double[n];
//input

File *file;
fopen(file,"sysb.txt","r");

double *vectors=vector_insert(n,file);


//cuda alloc






// solve





return 0;
}


//cuda function

void solve(){
  
  
  
}

/// 입출력

double* vector_insert(int n,File *file){

double *vectors=new double[n];
int i=0;
while(i<n &&   ){
fgetc(file,double[i]);

i++;

}

return vectors;
}
