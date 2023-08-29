etc/cron.root:
	sudo crontab -l | mkifdiff $@
slurm/slurm-env.txt:
	cd slurm && sbatch -o slurm-env.txt -e slurm-env.txt  slurm-test.bash
