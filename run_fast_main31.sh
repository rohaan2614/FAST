#!/usr/bin/bash

# Define the array of F values

LEARNING_RATE=0.01
NUM_CLIENTS=2
NUM_ROUNDS=50001
F_VALUES=(2000 5000)

# Loop through each value of F
for F in "${F_VALUES[@]}"; do
    # Create a SLURM script for each value of F
    cat <<EOL > "slurm_script_f_${F}.sh"
#!/usr/bin/bash
#SBATCH --job-name=ECGA-2H100_F_$F
#SBATCH --partition=tier3
#SBATCH --account=fl-het
#SBATCH --mem=16G
#SBATCH --time=5-00:00:00
#SBATCH --gres=gpu:h100:2
#SBATCH --mail-user=slack:@rn7823
#SBATCH --mail-type=ALL

# Get the current date
DATE_TIME=\$(date +"%Y-%m-%d_%H-%M")

# Define the output file names
OUTPUT_LOG="\${SLURM_JOB_ID}_output_F_${F}_clients_${NUM_CLIENTS}.log"
ERROR_LOG="\${SLURM_JOB_ID}_error_F_${F}_clients_${NUM_CLIENTS}.log"

# Activate the virtual environment
source venv/bin/activate

# Run the provided Python script and redirect output to files
python fast_main3.py --dataset=cifar10 --num-clients=$NUM_CLIENTS --round=$NUM_ROUNDS --f=$F --lr=$LEARNING_RATE --log-to-tensorboard=cifar_CNN > "output/\$OUTPUT_LOG" 2> "error/\$ERROR_LOG"

# Deactivate the virtual environment
deactivate
EOL

    # Submit the SLURM script
    sbatch "slurm_script_f_${F}.sh"
    rm "slurm_script_f_${F}.sh"
done
