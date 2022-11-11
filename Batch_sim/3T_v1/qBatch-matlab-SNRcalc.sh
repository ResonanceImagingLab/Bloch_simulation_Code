#!/bin/sh
#
#$ -cwd
#$ -o outputsSNR/out.txt
#$ -e outputsSNR/err.txt
#$ -m e
#$ -pe all.pe 20

matlab21b -nosplash -nodisplay < CR_batch_calculateSNR.m

