#!/bin/bash
#$ -P hollingsworth.prjc
#$ -wd /well/hollingsworth/users/vrl027/bstrap
#$ -N bstrap
#$ -pe shmem 1
#$ -o /well/hollingsworth/users/vrl027/bstrap
#$ -e /well/hollingsworth/users/vrl027/bstrap
#$ -q short.qc
#$ -t 1-100
#$ -tc 100

echo started=`date`
module purge
module load R/4.1.0-foss-2021a

echo "job=$JOB_ID"
echo "hostname="`hostname`
echo "OS="`uname -s`
echo "username="`whoami`
Rscript /well/hollingsworth/users/vrl027/bstrap/coef.bstrap.R ${SGE_TASK_ID} --no-save --no-restore
echo "finished="`date`
exit 0
