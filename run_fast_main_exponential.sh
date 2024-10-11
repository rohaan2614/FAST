#!/usr/bin/bash

# Define the array of F values
Gamma=(0.05 0.1 0.2 0.5)
F_VALUES=(2000 4000)
LEARNING_RATE=0.01
NUM_CLIENTS=2

# Loop through each value of F
for F in "${F_VALUES[@]}"; do
    # Loop through each value of Gamma
    for G in "${Gamma[@]}"; do
        # Create a SLURM script for each combination of F and Gamma
        cat <<EOL > "slurm_script_f_${F}_gamma_${G}.sh"
#!/usr/bin/bash
#SBATCH --job-name=FAST_2A100_F_${F}_Gamma_${G}
#SBATCH --partition=tier3
#SBATCH --account=fl-het
#SBATCH --mem=32G
#SBATCH --time=7-00:00:00
#SBATCH --gres=gpu:a100:2
#SBATCH --mail-user=slack:@rn7823
#SBATCH --mail-type=ALL

# Get the current date
DATE_TIME=\$(date +"%Y-%m-%d_%H-%M")

# Define the output file names
OUTPUT_LOG="\${SLURM_JOB_ID}_output_f_${F}_gamma_${G}_clients_${NUM_CLIENTS}.log"
ERROR_LOG="\${SLURM_JOB_ID}_error_f_${F}_gamma_${G}_clients_${NUM_CLIENTS}.log"

# Activate the virtual environment
source venv/bin/activate

# Run the provided Python script and redirect output to files
python fast_main_exponential.py --dataset=cifar10 --num-clients=$NUM_CLIENTS --f=$F --lrGamma=$G --lr=$LEARNING_RATE --log-to-tensorboard=cifar_CNN > "output/\$OUTPUT_LOG" 2> "error/\$ERROR_LOG"

# Deactivate the virtual environment
deactivate
EOL

        # Submit the SLURM script
        sbatch "slurm_script_f_${F}_gamma_${G}.sh"
        rm "slurm_script_f_${F}_gamma_${G}.sh"
    done
done
