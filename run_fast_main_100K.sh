#!/usr/bin/bash

# Define the array of F values
F_VALUES=(12000 17500 20000 15000)
LEARNING_RATE=0.01
NUM_CLIENTS=2


# Loop through each value of F
for F in "${F_VALUES[@]}"; do
    # Create a SLURM script for each value of F
    cat <<EOL > "slurm_script_f_${F}.sh"
#!/usr/bin/bash
#SBATCH --job-name=FAST_R_100K_F_$F
#SBATCH --partition=tier3
#SBATCH --account=fl-het
#SBATCH --mem=32G
#SBATCH --time=7-00:00:00
#SBATCH --gres=gpu:h100:2
#SBATCH --mail-user=slack:@rn7823
#SBATCH --mail-type=ALL

# Get the current date
DATE_TIME=\$(date +"%Y-%m-%d_%H-%M")

# Define the output file names
OUTPUT_LOG="\${SLURM_JOB_ID}_output_f_${F}_clients_${NUM_CLIENTS}.log"
ERROR_LOG="\${SLURM_JOB_ID}_error_f_${F}_clients_${NUM_CLIENTS}.log"

# Activate the virtual environment
source venv/bin/activate

# Run the provided Python script and redirect output to files
python fast_main3.py --dataset=cifar10 --num-clients=$NUM_CLIENTS --f=$F --lr=$LEARNING_RATE --round=100000 --log-to-tensorboard=cifar_CNN > "output/\$OUTPUT_LOG" 2> "error/\$ERROR_LOG"

# Deactivate the virtual environment
deactivate
EOL

    # Submit the SLURM script
    sbatch "slurm_script_f_${F}.sh"
    rm "slurm_script_f_${F}.sh"
done
