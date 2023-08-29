# HPC Enviornment for cerebro2
## Modules
not lmod () but  ["environment module"](https://modules.readthedocs.io/en/latest/)

`module --version`
> Modules Release 4.4.0 (2019-11-17)

 * binaries: `/cm/shared/apps/$APP/$VERSION/$FILES`
 * module.tcl: `/cm/shared/modulefiles/$APP/$VERSION`

### Apps

 * afni: from CRC but ported to tcl from lua. (20230828)
   * `/cm/shared/modulefiles/afni/21.3.06`
   * compiled libpng15.so and put directly in afni path
   * ignoring R dependency for now


## Guix
 * over nix b/c has explict HPC tutorial: https://guix.gnu.org/cookbook/en/html_node/Setting-Up-Compute-Nodes.html

## Mounts

NFS exports in `/etc/exports`

 * guix
 * Zeus

## Slurm

