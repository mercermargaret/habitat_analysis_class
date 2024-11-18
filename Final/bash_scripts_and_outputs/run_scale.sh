#!/bin/bash
#SBATCH --job-name=scales         # name of the job (make it short!)
#SBATCH --partition=standard           # partition to be used (standard OR windfall)
#SBATCH --account=jmalston          # hpc group name! (always jmalston)
#SBATCH --time=24:00:00            # walltime (up to 10-00:00:00(240:00:00))
#SBATCH --nodes=1                  # number of nodes
#SBATCH --ntasks-per-node=1        # number of tasks (i.e. parallel processes) to be started
#SBATCH --cpus-per-task=8          # number of cpus required to run the script
#SBATCH --mem-per-cpu=4G         # memory required for process
#SBATCH --array=0-33%34    	       # set number of total simulations and number that can run simultaneously (0-33%34)

ml R gdal/3.8.5

cd /home/u15/mmercer3/proj/habitat_analysis_class   # where executable and data is located

list=(/home/u15/mmercer3/proj/habitat_analysis_class/Final/Model_Fit_Results/*_rr.Rda)

date
echo "Initiating script"

Rscript Final/scales.R ${list[SLURM_ARRAY_TASK_ID]} # name of script
echo "Script complete"
date
