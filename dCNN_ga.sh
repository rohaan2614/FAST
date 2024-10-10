#!/usr/bin/bash
#SBATCH --partition=tier3
#SBATCH --account=fl-het
#SBATCH --mem=32G
#SBATCH --time=2-00:00:00
#SBATCH --gres=gpu:h100

# Get the current date
DATE_TIME=$(date +"%Y-%m-%d_%H-%M")

# Define the output file names
OUTPUT_LOG="${SLURM_JOB_ID}_output.log"
ERROR_LOG="${SLURM_JOB_ID}_error.log"

# Activate the virtual environment
source venv/bin/activate

LEARNING_RATE=0.01
F=200

# Run the provided Python script and redirect output to files
python fast_main_deep_cnn.py --dataset=cifar10 --num-clients=1 --f=$F --lr=$LEARNING_RATE --log-to-tensorboard=cifar_dCNN > "output/$OUTPUT_LOG" 2> "error/$ERROR_LOG"

# Deactivate the virtual environment
deactivate
