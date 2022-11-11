#!/bin/sh
#
#$ -cwd
#$ -o outputsBoost4/out.txt
#$ -e outputsBoost4/err.txt
#$ -m e
#$ -pe all.pe 10

matlab21b -nosplash -nodisplay < sim_ihMT_cortex3T_v4_BATCH_boost_part2.m

