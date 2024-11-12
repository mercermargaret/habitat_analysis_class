#!/bin/bash
#SBATCH --job-name=test         # name of the job (make it short!)
#SBATCH --partition=standard           # partition to be used (standard OR windfall)
#SBATCH --account=jmalston          # hpc group name! (always jmalston)
#SBATCH --time=48:00:00            # walltime (up to 10-00:00:00(240:00:00))
#SBATCH --nodes=4                  # number of nodes
#SBATCH --ntasks-per-node=1        # number of tasks (i.e. parallel processes) to be started
#SBATCH --cpus-per-task=1          # number of cpus required to run the script
#SBATCH --mem-per-cpu=32G         # memory required for process
#SBATCH --array=0-1%2    	   # set number of total simulations and number that can run simultaneously (0-33%34)

ml R gdal/3.8.5

cd /home/u15/mmercer3/proj/habitat_analysis   # where executable and data is located

list=(/home/u15/mmercer3/proj/habitat_analysis/Final/Bobcat_Individuals/range_resident/*.csv)

date
echo "Initiating script"

Rscript Final/analysis.R ${list[SLURM_ARRAY_TASK_ID]} # name of script
echo "Script complete"
date