(use-modules
 (gnu packages algebra)
 (gnu packages check)
 (gnu packages commencement)
 (gnu packages compression)
 (gnu packages fontutils)
 (gnu packages geo)
 (gnu packages gl)
 (gnu packages lesstif) ;motif (libXm.so)
 (gnu packages image) ; libjpeg-turbo (but not the right one. want libjpeg6)
 (gnu packages image-processing)
 (gnu packages statistics) ; r
 (gnu packages maths) ;openblas
 (gnu packages python)
 (gnu packages base)
 (gnu packages shells)
 (gnu packages netpbm)
 (gnu packages xml)
 (gnu packages xorg)
 (gnu packages graphviz) ;gts -- GNU Triangulated Surface
 (guix build-system gnu)
 (guix build-system cmake)
 (guix git-download)
 ((guix licenses) #:prefix license:)
 (guix packages))

(include "giftilib.scm")

(define-public afni
  (package
    (name "afni")
    (version "23.3.01") ; fetched 20231014; 2 days old
    (home-page "https://afni.nimh.nih.gov")
    (license license:gpl3)
    (synopsis "Analysis of Functional NeuroImages")
    (description "Analysis of Functional NeuroImages is a leading software suite of C, Python, R programs and shell scripts primarily developed for the analysis and display of multiple MRI modalities: anatomical, functional MRI (FMRI) and diffusion weighted (DW) data. ")

    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/afni/afni")
             (commit (string-append "AFNI_" version))
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1ss5w1m15a8qk08dyk4vp5knpa3dyp043mzi1xwhaq58bs4gfgci"))))
    (inputs        (list giftilib glu libxp tcsh libpng netpbm openblas libxml2 gsl libjpeg-turbo python r libice ))
    (native-inputs (list clapack niftilib gts motif glu coreutils libx11 libxft libxp tcsh libpng netpbm openblas libxml2 gsl libjpeg-turbo python r gcc-toolchain libice niftilib giftilib))
;    (native-inputs `(("clapack" ,clapack)
;                     ("gts" ,gts)
;                     ("glu" ,glu)
;                     ("coreutils" ,coreutils)
;                     ("tcsh" ,tcsh)
;                     ("openblas" ,openblas)
;                     ("libxml2", libxml2)
;                     ("gsl" ,gsl)
;                     ("python", python)
;                     ("r" ,r)
;                     ("gcc-toolchain" ,gcc-toolchain)
;                     ("libice" ,libice)
;                     ("niftilib" ,niftilib)
;                     ("giftilib" ,giftilib)
;                     ;("nifticlib" ,(origin
;                     ;               (method git-fetch)
;                     ;               (uri (git-reference (url "https://github.com/NIFTI-Imaging/nifti_clib.git")
;                     ;                                   (commit "75180f776997bd161c5b231dfffb65e6385f5f93")))
;                     ;               (sha256 (base32 "1kb7ys5278vadiln1w9ssff1jmx33zbg6h36m8kkiqdjspqw4q8g"))))
;                     ;("giftilib" ,(origin
;                     ;               (method git-fetch)
;                     ;               (uri (git-reference (url "https://github.com/NIFTI-Imaging/gifti_clib.git")
;                     ;                                   (commit "5eae81ba1e87ef3553df3b6ba585f12dc81a0030")))
;                     ;               (sha256 (base32 "1kb7ys5278vadiln1w9ssff1jmx33zbg6h36m8kkiqdjspqw4q8g"))))
;))
   (build-system cmake-build-system)
   (arguments
     (list
      #:configure-flags '(list "-DAFNI_COMPILER_CHECK=OFF" ;"-DCOMP_GUI=OFF"
                               "-DCOMP_SUMA=OFF" "-DUSE_SYSTEM_ALL=ON"
                               "-DFORCE_CURRENT_PY_INTERP_FOR_TESTS=ON")))
   ; (build-system gnu-build-system)
   ; (arguments
   ;  (list
   ;   #:make-flags '(list "install")
   ;   #:phases
   ;    '(modify-phases %standard-phases
   ;       (add-after 'unpack 'add-makefile
   ;         (lambda* (#:key outputs #:allow-other-keys)
   ;           (invoke "sh" "-c"
   ;                   "echo -e true >> configure; chmod +x configure")
   ;           (invoke "sh" "-c"
   ;                   "echo -e 'install:\n\tPREFIX=$PWD/bin make -C src -f Makefile.linux_openmp_64 vastness' >> Makefile")
   ;           )))
))
    ; tcsh xfonts-base
    ; python-is-python3 python3-matplotlib python3-numpy python3-flask python3-flask-cors python3-pil
    ; gsl-bin netpbm
    ; libjpeg62
    ; libglu1-mesa-dev libglw1-mesa
    ; libxm4
    ; libxml2-dev
    ; libgomp1
    ; r-base-dev
    ; libgdal-dev libopenblas-dev
    ; libnode-dev libudunits2-dev
    ;
    ; wants libgsl.so.19
;     less '/var/log/guix/drvs/6k/ys2858ip0f1ns5vi1vhbffj6l2pr3f-afni-3.22.drv.gz'|grep -Po "(?<=depends on ')[^']*"|sort -u
;libfontconfig.so.1
;libgcc_s.so.1
;libglib-2.0.so.0
;libGL.so.1
;libGLU.so.1
;libgomp.so.1
;libgslcblas.so.0
;libgsl.so.0
;libICE.so.6
;libjpeg.so.62
;libpng12.so.0
;libR.so
;libSM.so.6
;libstdc++.so.6
;libX11.so.6
;libXext.so.6
;libXft.so.2
;libXmu.so.6
;libXpm.so.4
;libXp.so.6
;libXt.so.6
;libz.so.1

afni
