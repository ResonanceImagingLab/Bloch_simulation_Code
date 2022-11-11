# http://www.bic.mni.mcgill.ca/Services/HowToUseSgeBatch

############ check the above for notes on how to run qbatch for Matlab. Here I provide some
# quick notes:

# First we create the relevent files and directories and then we send the job to be processed. 
# Create a directory to contain your scripts, matlab .m files and the job output files: 


mkdir /my/big/data/eve
cd /my/big/data/eve
mkdir output

###### Make the following script in output folder above    #############
# which calls your matlab script qBatch-matlab.m           #############

##### Start ##### - dont include this line                 #############

#!/bin/sh
#
#$ -cwd
#$ -o output/out.txt
#$ -e output/err.txt
#$ -m e

matlab -nosplash -nodisplay -nojvm < qBatch-matlab.m

##### END ##### - dont include this line               #############

############# Next make this bash script executeable:  #############
chmod u+x test-matlab.sh




##############    Submit the job:                      #############
qsub -q all.q ./test-matlab.sh

############# Check the status of all your jobs:       #############

qstat -u yourUsername


##############################################################################
## Key things to specify for parallelization
################################################################################

############## in your matlab script include:  ##############
parpool(str2num(getenv('NSLOTS')));

############## And include this at the top of your script: ##############
cl = parcluster('local');
cl.NumWorkers = 10;
saveProfile(cl);

# IF RUNNING PARALLELIZED MATLAB, REMOVE THE -nojvm FLAG IN YOU BASH SCRIPT


# chmod u+x qBatch-matlab-Boost.sh
chmod u+x qBatch-matlab-Conventional.sh


chmod u+x qBatch-matlab-Boost_part1_1.sh
chmod u+x qBatch-matlab-Boost_part1_2.sh
chmod u+x qBatch-matlab-Boost_part1_3.sh

chmod u+x qBatch-matlab-SNRcalc.sh


# Submit:
qsub -q all.q ./qBatch-matlab-Conventional.sh
#qsub -q all.q ./qBatch-matlab-Boost.sh

qsub -q all.q ./qBatch-matlab-Boost_part1_1.sh
qsub -q all.q ./qBatch-matlab-Boost_part1_2.sh
qsub -q all.q ./qBatch-matlab-Boost_part1_3.sh

qsub -q all.q ./qBatch-matlab-Boost_part2.sh

qsub -q all.q ./qBatch-matlab-SNRcalc.sh

# Check status
qstat -u crowley

## monitor jobs

qstat -j <job-id> 


## Cancelling jobs
qstat -u crowley

# get job ID then delete with
qdel <job-ID>




















