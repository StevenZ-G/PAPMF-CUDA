#include <stdlib.h>
#include <stdio.h>
#include <fstream>
#include <cuda.h>
#include <iostream>
#include <iomanip>
#include <time.h>

using namespace std;
#define TILE 16

  
// Inicializa las matrices en memoria del dispositivo (GPU)
void initialize_matrices(double** da, double** dl, int size) {
    // Asignar memoria en el dispositivo para las matrices A y L
    cudaMalloc((void**)da, size * size * sizeof(double));  // para la matriz A
    cudaMalloc((void**)dl, size * size * sizeof(double));  // para la matriz L
    
    // Inicializa la matriz L con ceros
    cudaMemset(*dl, 0, size * size * sizeof(double));
}

__global__ void scaleIndex(double *matrix, int n, int index){
  int start=(index*n+index);
	int end=(index*n+n);
	
	for(int i= start+1 ; i<end; ++i){
		matrix[i]=(matrix[i]/matrix[start]);
	}

}

__global__ void elim(double *A, int n, int index, int bsize){
	extern __shared__ double pivot[];

	int idThread=threadIdx.x;
	int idBlock=blockIdx.x;
	int blockSize=bsize;


	if(idThread==0){
	     for(int i=index;i<n;i++) pivot[i]=A[(index*n)+i];
	}

	__syncthreads();
  //Varitables for pivot, row, start and end
	int pivotRow=(index*n);
	int currentRow=(((blockSize*idBlock) + idThread)*n);
	int start=currentRow+index;
	int end=currentRow+n;
  //If greater than pivot row, loop from start index + 1(next row) to end of column
	if(currentRow >pivotRow){
    for(int i= start+1; i<end; ++i){
        //Set the matrix value of next row and its column - pivot
        A[i]=A[i]-(A[start]*pivot[i-currentRow]);

             }
      }
}
//Randomly generated diagonal dominant (non-singular) matrix - 1D
void fillMatrix(double* a, int n){
  // Fill the matrix
   for (int i = 0; i <= (n*n); ++i) {
    a[i] =((rand()%10)+1);
  }

  //Make the matrix diagonally dominant to guarantee it is non-singular (invertible)
  int diagCount = 0;
  double sum = 0;
  for(int i = 0; i < n; ++i){
    //Iterate through the row, add all the values, remove the diagonal value
    for(int j = i*n; j < i*n + n; ++j){
      sum += abs(a[j]);
      //printf("%f +", sum);
    }
    ///Remove the diagonal value
    //i*n gives us the current row, then  add diagCount to get to correct column
    sum -= abs(a[i*n + diagCount]);
    //Add random value to the new sum, this guarantees diagonal is now larger than row sum
    a[i*n + diagCount] = sum + ((rand()%5)+1);
    ++diagCount;
    sum = 0;
  }

}

void printMatrix(double* a, int n){
    for(int i=0; i<(n*n); ++i){
           if(i%n==0)
       		   cout << endl << left << setw(9) << setprecision(3) << a[i] << left <<  setw(9);
           else cout << left << setw(9) << setprecision(3) << a[i] << left <<  setw(9);
         }
    printf("\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
    cout << endl;
}
//----------------------------------------------------------------------- 
//Print 2D Matrix
//----------------------------------------------------------------------- 
void print2D(double** matrix, int size)
{
  //for each row...
  for (int i = 0; i < size; i++)
  {
    //for each column
    for (int j = 0; j < size; j++)
    {
      //print out the cell
      cout << left << setw(9) << setprecision(3) << matrix[i][j] << left <<  setw(9);
    }
    //new line when ever row is done
    cout << endl;
  }
}

__global__ void choleskyScale(double* da, int n, int i) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= n) return;

    if (index == i) {
        // Diagonal element: compute sqrt
        da[i * n + i] = sqrt(da[i * n + i]);
    }
}

__global__ void choleskyElim(double* da, int n, int i, int tile) {
    int row = blockIdx.x * tile + threadIdx.x;
    int col = blockIdx.y * tile + threadIdx.y;

    if (row >= n || col >= n) return;

    if (row > i && col >= i) {
        // Eliminate elements using Cholesky formula: L[i,j] = (A[i,j] - sum) / L[i,i]
        double sum = 0.0;
        for (int k = 0; k < i; ++k) {
            sum += da[row * n + k] * da[col * n + k];
        }
        da[row * n + col] = (da[row * n + col] - sum) / da[i * n + i];
    }
}


int main(int argc, char** argv) {
    // Definimos la dimensión de la matriz
    int n = atoi(argv[1]);

    srand(1);

    // Asignamos memoria para la matriz A y el resultado (matriz L)
    double* a = new double[n * n];
    double* ret = new double[n * n];

    // Llenamos la matriz A
    fillMatrix(a, n);

    // Asignamos memoria en el dispositivo para A y L
    double* da;
    double* dl;
    int numblock = n / TILE + ((n % TILE) ? 1 : 0);

    double runtime;
    runtime = clock() / (double)CLOCKS_PER_SEC;
    
    // Asignamos memoria para las matrices en el dispositivo
    initialize_matrices(&da, &dl, n);

    // Transferimos la matriz A del host al dispositivo
    cudaMemcpy(da, a, n * n * sizeof(double), cudaMemcpyHostToDevice);

    // Descomposición de Cholesky: Calculamos L
    for (int i = 0; i < n; ++i) {
        // Escalamos el valor diagonal
        choleskyScale<<<1, 1>>>(da, n, i);

        // Eliminamos los valores debajo de la diagonal
        choleskyElim<<<dim3(numblock, numblock), dim3(TILE, TILE)>>>(da, n, i, TILE);
    }

    // Transferimos el resultado de vuelta al host
    cudaMemcpy(ret, da, n * n * sizeof(double), cudaMemcpyDeviceToHost);

    runtime = clock() - runtime;
    printf("For %u x %u Matrix\n", n, n);
    std::cout << "Runtime for Cholesky Decomposition is: " << (runtime) / float(CLOCKS_PER_SEC) << std::endl;

    // Crear matrices 2D para L
    double** l = new double* [n];
    
    // La inicialización de la matriz L debe realizarse en el host, no en la GPU
    // Asignamos memoria para la matriz L en el host
    for (int i = 0; i < n; ++i) {
        l[i] = new double[n];
    }

    // Extraemos L del resultado
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (i >= j) {
                l[i][j] = ret[i * n + j];
            } else {
                l[i][j] = 0.0;
            }
        }
    }

    // Imprimir matriz L
    if (atoi(argv[2]) == 1) {
        printf("Matrix 'A' is:\n");
        printMatrix(a, n);
        printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        printf("Matrix 'L' is:\n");
        print2D(l, n);
    }

    // Liberamos memoria
    cudaFree(da);
    cudaFree(dl);
    delete[] a;
    delete[] ret;

    return 0;
}
