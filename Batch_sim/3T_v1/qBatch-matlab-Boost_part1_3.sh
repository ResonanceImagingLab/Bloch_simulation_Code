#!/bin/sh
#
#$ -cwd
#$ -o outputsBoost3/out.txt
#$ -e outputsBoost3/err.txt
#$ -m e
#$ -pe all.pe 20

matlab21b -nosplash -nodisplay < sim_ihMT_cortex3T_v4_BATCH_boost_part1_3.m

