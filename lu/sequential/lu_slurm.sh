#!/bin/bash
#SBATCH --job-name=u_sequential         # Nombre del trabajo
#SBATCH --partition=cpu-max             # Partición donde ejecutar el trabajo (ajústalo según la configuración de tu clúster)
#SBATCH --nodes=1                       # Número de nodos necesarios
#SBATCH --ntasks=1                      # Número de tareas
#SBATCH --cpus-per-task=1               # Número de CPUs por tarea (puedes ajustarlo dependiendo de tu código)
#SBATCH --mem=4G                        # Memoria solicitada por nodo (ajusta según lo que necesites)
#SBATCH --time=01:00:00                 # Tiempo máximo de ejecución del trabajo
#SBATCH --output=lu_output.%j.log  # Archivo de salida
#SBATCH --error=lu_error.%j.log    # Archivo de errores

# Cargar módulos si es necesario
# module load gcc/9.2.0
# module load openmpi/4.0.3

# Ejecutar el código de LU
./lu_sequential "$@"

# Mostrar información del trabajo
echo '=====================JOB DIAGNOSTICS========================'
date
echo -n 'This machine is '; hostname
echo -n 'My jobid is '; echo $SLURM_JOBID
echo 'My path is:' $PATH
echo 'Job info:'
squeue -j $SLURM_JOBID
echo 'Machine info:'
sinfo -s
echo '========================ALL DONE==========================='
