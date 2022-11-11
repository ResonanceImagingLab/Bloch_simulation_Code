#!/bin/sh
#
#$ -cwd
#$ -o outputsBoost1/out.txt
#$ -e outputsBoost1/err.txt
#$ -m e
#$ -pe all.pe 20

matlab21b -nosplash -nodisplay < sim_ihMT_cortex3T_v4_BATCH_boost_part1_1.m

