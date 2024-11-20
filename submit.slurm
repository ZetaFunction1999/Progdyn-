#!/bin/bash
#SBATCH --job-name=QCT-MD
#SBATCH --partition=cpu
#SBATCH -N 1
#SBATCH --ntasks-per-node=40
#SBATCH --output=/lustre/home/acct-clsst/clsst/Liu/slog/%j_%x.out
#SBATCH --error=/lustre/home/acct-clsst/clsst/Liu/slog/%j_%x.err

export OMP_STACKSIZE=3000M

bash QCT-MD.sh

