#%Module -*- tcl -*-
# 2023-08-28 WF - tcl port of CRC's LMod lua module
# copied tgz directly from there
# sudo tar -zvf linux_centos_7_64.tgz -C /cm/shared/apps/afni/21.3.06/ -x
# wget https://newcontinuum.dl.sourceforge.net/project/libpng/libpng15/1.5.30/libpng-1.5.30.tar.gz
#   ./configure && make && sudo cp ./.libs/libpng15.so.15 $(dirname $(which afni))
#
proc ModulesHelp { } {
  puts stderr "\tAdds AFNI to your environment."
  puts stderr "\tDirectory: /cm/shared/apps/afni/21.3.06/linux_centos_7_64"
}

# Description
module-whatis "Name: AFNI"
module-whatis "Version: 21.3.06"
module-whatis "Description: AFNI is a set of C programs for processing, analyzing, and displaying functional MRI (FMRI) data - a technique for mapping human brain activity."
module-whatis "Keywords: AFNI fMRI"
module-whatis "URL: https://afni.nimh.nih.gov"
module-whatis "module ported from CRC's lmod version"

# Package Root
set root "/cm/shared/apps/afni/21.3.06/linux_centos_7_64"

# Requires these packages
#load("gcc/8.2.0", "r/4.0.0")


# PATHs
prepend-path      PATH              $root
