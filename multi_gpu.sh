#!/usr/bin/bash
#SBATCH --job-name=multi_GPU
#SBATCH --partition=debug
#SBATCH --account=fl-het
#SBATCH --mem=4G
#SBATCH --time=1-00:00:00
#SBATCH --gres=gpu:a100:2
#SBATCH --mail-user=slack:@rn7823
#SBATCH --mail-type=ALL

# Define the output file names
OUTPUT_LOG="${SLURM_JOB_ID}_output_multi_GPU.log"
ERROR_LOG="${SLURM_JOB_ID}_error_multi_GPU.log"

# Activate the virtual environment
source venv/bin/activate

# Run the provided Python script and redirect output to files
python exp_parallel_gpu_ones.py > "output/$OUTPUT_LOG" 2> "error/$ERROR_LOG"

# Deactivate the virtual environment
deactivate
