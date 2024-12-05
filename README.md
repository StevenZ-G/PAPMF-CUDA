# Performance Analysis of Parallel Matrix Factorization Using CUDA

This repository presents the implementation and performance analysis of LU and Cholesky matrix factorizations using CUDA to leverage GPU acceleration. The project compares sequential and parallel implementations for matrices of varying sizes, demonstrating significant performance improvements achieved with parallelization.

The experiments were conducted using the HPC cluster provided by CEDIA, allowing scalable and efficient execution of the CUDA-based programs.

## Prerequisites

Before proceeding, ensure that the following requirements are met:

- Access to an HPC cluster supporting SLURM workload manager.
- NVIDIA GPUs with CUDA toolkit installed.
- GCC compiler for sequential implementations.
- Basic understanding of SLURM commands to manage jobs.

## Repository Structure

The repository is organized into directories corresponding to the two matrix factorization methods:

- **`cholesky`**: Contains CUDA and sequential implementations for Cholesky factorization.
- **`lu`**: Contains CUDA and sequential implementations for LU factorization.

Each method's directory has subdirectories for the specific implementation type (`cuda` and `sequential`).

## How to Run the Programs

Follow these steps to compile and execute the programs:

### Clone the Repository

Begin by cloning this repository to your local environment:

```bash
git clone https://github.com/StevenZ-G/PAPMF-CUDA.git
cd PAPMF-CUDA
```

# Cholesky Factorization

## Cuda Implementation

1) Navigate to the CUDA implementation directory:

```bash
cd cholesky/cuda
```

2) Compile the CUDA program using nvcc:

```bash
nvcc -o cholesky cholesky.cu
```

3) Submit the job to the SLURM queue:

```bash
sbatch cholesky_slurm.sh [matrix_size]
```

4) Verify the job submission:

```bash
squeue -u $USER
```

## Sequential Implementation

1) Navigate to the sequential implementation directory:

```bash
cd ../sequential
```

2) Compile the sequential program using g++:

```bash
g++ -o cholesky_sequential cholesky_sequential.cpp
```

3) Submit the job to the SLURM queue:

```bash
sbatch cholesky_slurm.sh [matrix_size]
```

4) Verify the job submission:

```bash
squeue -u $USER
```

# LU Factorization

## Cuda Implementation

1) Navigate to the CUDA implementation directory:

```bash
cd ../../lu/cuda
```

2) Compile the CUDA program using nvcc:

```bash
nvcc -o lu lu_cuda.cu
```

3) Submit the job to the SLURM queue:

```bash
sbatch lu_slurm.sh [matrix_size]
```

4) Verify the job submission:

```bash
squeue -u $USER
```

## Sequential Implementation

1) Navigate to the sequential implementation directory:

```bash
cd ../sequential
```

2) Compile the sequential program using g++:

```bash
g++ -o lu_sequential lu_sequential.cpp
```

3) Submit the job to the SLURM queue:

```bash
sbatch lu_slurm.sh [matrix_size]
```

4) Verify the job submission:

```bash
squeue -u $USER
```

# Performance Analysis

## Experiment Setup

To conduct performance analysis:
- Modify [matrix_size] in the SLURM submission script to test different matrix dimensions.
- Compare execution times and resource utilization across CUDA and sequential implementations.

## Key Metrics

1. Execution Time: Measure the runtime for different matrix sizes.
2. Speedup: Calculate the ratio of sequential time to parallel time.
3. Scalability: Evaluate performance as the matrix size increases.


## Troubleshooting

# Common Issues

1. CUDA Errors:
    - Ensure the CUDA toolkit is correctly installed.
    - Verify GPU availability with `nvidia-smi`.

2. SLURM Job Submission:
    - Ensure SLURM scripts are configured for your cluster's specifications.
    - Check SLURM queue status for errors using:
    ```bash
    squeue -u $USER
    ```

3. Compilation Errors:
    - Use compatible compiler versions (e.g., `nvcc` for CUDA, `g++` for sequential).