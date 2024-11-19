#!/bin/bash
#SBATCH --job-name=1500         # name of the job (make it short!)
#SBATCH --partition=standard           # partition to be used (standard OR windfall)
#SBATCH --account=jmalston          # hpc group name! (always jmalston)
#SBATCH --time=12:00:00            # walltime (up to 10-00:00:00(240:00:00))
#SBATCH --nodes=1                  # number of nodes
#SBATCH --ntasks-per-node=1        # number of tasks (i.e. parallel processes) to be started
#SBATCH --cpus-per-task=8          # number of cpus required to run the script
#SBATCH --mem-per-cpu=8G         # memory required for process
#SBATCH --array=0-13%14    	       # set number of total simulations and number that can run simultaneously

ml R gdal/3.8.5

cd /home/u15/mmercer3/proj/habitat_analysis_class   # where executable and data is located

list=(/home/u15/mmercer3/proj/habitat_analysis_class/Final/Model_Fit_Results/roads_1500/*Rda)

date
echo "Initiating script"

Rscript Final/scripts/analysis_1500.R ${list[SLURM_ARRAY_TASK_ID]} # name of script
echo "Script complete"
date
