#!/usr/bin/bash
#SBATCH --partition=tier3
#SBATCH --account=fl-het
#SBATCH --mem=32G
#SBATCH --time=2-00:00:00
#SBATCH --gres=gpu:a100

# Get the current date
DATE_TIME=$(date +"%Y-%m-%d_%H-%M")

# Define the output file names
OUTPUT_LOG="${SLURM_JOB_ID}_output.log"
ERROR_LOG="${SLURM_JOB_ID}_error.log"

# Activate the virtual environment
source venv/bin/activate

# Run the provided Python script and redirect output to files
python fast_main.py \
    --dataset=cifar10 \
    --f=100 \
    --train-batch-size=128 \
    --test-batch-size=256 \
    --lr=0.01 \
    --sampling-type=uniform \
    --local-update=1 \
    --num-clients=2 \
    --round=10000 \
    --q=1 \
    --alpha=1 \
    --seed=365 \
    --algo=fedavg \
    --log-to-tensorboard=cifar10_deep_cnn \
    --eval-iterations=10 > "output/$OUTPUT_LOG" 2> "error/$ERROR_LOG"

# Deactivate the virtual environment
deactivate
