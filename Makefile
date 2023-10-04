etc/cron.root:
	./sync_etc.bash
slurm/slurm-env.txt:
	cd slurm && sbatch -o slurm-env.txt -e slurm-env.txt  slurm-test.bash
