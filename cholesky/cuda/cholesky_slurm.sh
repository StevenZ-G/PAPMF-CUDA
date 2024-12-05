#!/bin/bash
#SBATCH --job-name=choleskycode       # Nombre del trabajo
#SBATCH --partition=gpu-dev           # Usa la partición gpu-dev
#SBATCH --gres=gpu:1                  # Solicita 1 GPU
#SBATCH --mem=16G                     # Ajusta la memoria solicitada
#SBATCH --output=slurm_output.%j      # Archivo de salida
#SBATCH --error=slurm_error.%j        # Archivo de error

# Cargar módulo de CUDA si es necesario (reemplaza por la versión en tu entorno)
module load cuda/11.8

# Ejecutar el programa
nsys profile ./cholesky "$@"    # Ejecuta tu programa de Cholesky con cualquier parámetro

# Diagnóstico
echo '=====================JOB DIAGNOTICS========================'
date
echo -n 'This machine is '; hostname
echo -n 'My jobid is '; echo $SLURM_JOBID
echo 'My path is:' 
echo $PATH
echo 'My job info:'
squeue -j $SLURM_JOBID
echo 'Machine info'
sinfo -s
echo '========================ALL DONE==========================='
