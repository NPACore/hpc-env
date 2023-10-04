# HPC Environment for cerebro2
This repo is on `/raidzeus/src/hpc-env` and in github (private) https://github.com/npacore/hpc-env

  * `docs/` documents modifications to the environment
  * `modules/` stores "environment module" modules (see below)
  * `etc/` tracks head node (cerebro2) settings, despite these being mostly managed by `Bright Cluster Manager`.

## Modules
["environment module"](https://modules.readthedocs.io/en/latest/) not not [lmod](https://lmod.readthedocs.io/en/latest/)

`module --version`
> Modules Release 4.4.0 (2019-11-17)

 * binaries: `/cm/shared/apps/$APP/$VERSION/$FILES`
 * module.tcl: `/cm/shared/modulefiles/$APP/$VERSION`

### Apps

 * afni: from CRC but ported to tcl from lua. (20230828)
   * `/cm/shared/modulefiles/afni/21.3.06`
   * compiled libpng15.so and put directly in afni root
   * ignoring R dependency for now. `ldd $(which afni)` has no "not found"


## Guix
 * Using instead of `nix` b/c has explicit [HPC tutorial](https://guix.gnu.org/cookbook/en/html_node/Setting-Up-Compute-Nodes.html)

## Mounts

NFS exports for guix and zeus in `/etc/exports`. Managed by bright view. see [`nfs_mounts.md`][docs/nfs_mounts.md)


## Slurm
see `slurm/slurm-env.txt` (and `Makefile`)
