#!/usr/bin/bash

# Define the array of F values
F_VALUES=(18000 16000 14000 12000 10000 5000 1000)
LEARNING_RATE=0.01
NUM_CLIENTS=100
ROUND=100000


# Loop through each value of F
for F in "${F_VALUES[@]}"; do
    # Create a SLURM script for each value of F
    cat <<EOL > "slurm_script_f_${F}.sh"
#!/usr/bin/bash
#SBATCH --job-name=FAST_C_100_F_$F
#SBATCH --partition=tier3
#SBATCH --account=fl-het
#SBATCH --mem=8G
#SBATCH --time=1-10:00:00
#SBATCH --gres=gpu:h100:2
#SBATCH --mail-user=slack:@rn7823
#SBATCH --mail-type=ALL

# Get the current date
DATE_TIME=\$(date +"%Y-%m-%d_%H-%M")

# Define the output file names
OUTPUT_LOG="\${SLURM_JOB_ID}_output_f_${F}_clients_${NUM_CLIENTS}_0.2_participation.log"
ERROR_LOG="\${SLURM_JOB_ID}_error_f_${F}_clients_${NUM_CLIENTS}_0.2_participation.log"

# Activate the virtual environment
source venv/bin/activate

# Run the provided Python script and redirect output to files
python fast_main3.py --dataset=cifar10 --num-clients=$NUM_CLIENTS --f=$F --lr=$LEARNING_RATE --round=$ROUND --log-to-tensorboard=cifar_CNN_0.2_Participation > "output/\$OUTPUT_LOG" 2> "error/\$ERROR_LOG"

# Deactivate the virtual environment
deactivate
EOL

    # Submit the SLURM script
    sbatch "slurm_script_f_${F}.sh"
    rm "slurm_script_f_${F}.sh"
done
