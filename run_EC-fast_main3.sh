#!/usr/bin/bash

# Define the array of F values

P_VALUES=(100)
LEARNING_RATE=0.01
NUM_CLIENTS=2
NUM_ROUNDS=100001
F_VALUE=(1000)

# Loop through each value of F
for P in "${P_VALUES[@]}"; do
    # Create a SLURM script for each value of F
    cat <<EOL > "slurm_script_p_${P}.sh"
#!/usr/bin/bash
#SBATCH --job-name=ECGA-H100x2_p_$P
#SBATCH --partition=tier3
#SBATCH --account=fl-het
#SBATCH --mem=16G
#SBATCH --time=0-03:00:00
#SBATCH --gres=gpu:h100:2
#SBATCH --mail-user=slack:@rn7823
#SBATCH --mail-type=ALL

# Get the current date
DATE_TIME=\$(date +"%Y-%m-%d_%H-%M")

# Define the output file names
OUTPUT_LOG="\${SLURM_JOB_ID}_output_P_${P}_clients_${NUM_CLIENTS}.log"
ERROR_LOG="\${SLURM_JOB_ID}_error_P_${P}_clients_${NUM_CLIENTS}.log"

# Activate the virtual environment
source venv/bin/activate

# Run the provided Python script and redirect output to files
python fast_main3.py --dataset=cifar10 --num-clients=$NUM_CLIENTS --round=$NUM_ROUNDS --f=$F_VALUE --p=$P --lr=$LEARNING_RATE --log-to-tensorboard=cifar_CNN > "output/\$OUTPUT_LOG" 2> "error/\$ERROR_LOG"

# Deactivate the virtual environment
deactivate
EOL

    # Submit the SLURM script
    sbatch "slurm_script_p_${P}.sh"
    rm "slurm_script_p_${P}.sh"
done
