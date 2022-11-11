#!/bin/sh
#
#$ -cwd
#$ -o outputsBoost/out.txt
#$ -e outputsBoost/err.txt
#$ -m e
#$ -pe all.pe 20

matlab21b -nosplash -nodisplay < sim_ihMT_cortex3T_v4_BATCH_boost1.m

