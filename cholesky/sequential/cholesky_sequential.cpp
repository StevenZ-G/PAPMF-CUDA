#include <iostream>
#include <iomanip>
#include <cmath>
#include <cstdlib>
#include <ctime>
using namespace std;

void print_matrix(float**, int);

// Function to print the matrix
void print_matrix(float** matrix, int size)
{
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            cout << left << setw(9) << setprecision(3) << matrix[i][j] << left << setw(9);
        }
        cout << endl;
    }
}

// Function to perform Cholesky decomposition
void cholesky_decomposition(float** a, float** l, int size)
{
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j <= i; j++)
        {
            float sum = 0;

            // Summation for diagonal elements
            if (i == j)
            {
                for (int k = 0; k < j; k++)
                    sum += pow(l[j][k], 2);

                l[j][j] = sqrt(a[j][j] - sum);
            }
            else
            {
                // Summation for non-diagonal elements
                for (int k = 0; k < j; k++)
                    sum += l[i][k] * l[j][k];

                l[i][j] = (a[i][j] - sum) / l[j][j];
            }
        }
    }
}

// Initialize the matrices
void initialize_matrices(float** a, float** l, int size)
{
    for (int i = 0; i < size; ++i)
    {
        a[i] = new float[size];
        l[i] = new float[size];

        for (int j = 0; j < size; j++)
            l[i][j] = 0; // Initialize L as zero
    }
}

// Fill the matrix with random values and ensure it's positive definite
void random_fill(float** matrix, int size)
{
    // Fill matrix with random values
    cout << "Producing random values " << endl;
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            matrix[i][j] = ((rand() % 10) + 1);
        }
    }

    // Make the matrix symmetric and positive definite
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            matrix[i][j] = (matrix[i][j] + matrix[j][i]) / 2;
        }
        matrix[i][i] += size; // Add a value to diagonal elements to make it positive definite
    }
}

int main(int argc, char** argv)
{
    double runtime;

    // Seed RNG
    srand(1);

    // Size of the matrix
    int size = atoi(argv[1]);

    // Initialize matrices
    float** a = new float* [size];
    float** l = new float* [size];
    initialize_matrices(a, l, size);

    // Fill A with random values
    random_fill(a, size);

    // Print A
    cout << "A Matrix: " << endl;
    // print_matrix(a, size);

    // Perform Cholesky decomposition
    runtime = clock() / (double)CLOCKS_PER_SEC;
    cholesky_decomposition(a, l, size);
    runtime = (clock() / (double)CLOCKS_PER_SEC) - runtime;

    // Print L
    cout << "L Matrix: " << endl;
    // print_matrix(l, size);

    // Calculate and print runtime
    cout << "Runtime: " << runtime << " seconds" << endl;

    // Free memory
    for (int i = 0; i < size; ++i)
    {
        delete[] a[i];
        delete[] l[i];
    }
    delete[] a;
    delete[] l;

    return 0;
}
