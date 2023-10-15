(use-modules
 (gnu packages algebra)
 (gnu packages check)
 (gnu packages commencement)
 (gnu packages compression)
 (gnu packages fontutils)
 (gnu packages geo)
 (gnu packages gl)
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
 (guix build-system gnu)
 (guix git-download)
 ((guix licenses) #:prefix license:)
 (guix packages))

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
    (inputs        (list libx11 libxft libxp tcsh libpng netpbm openblas libxml2 gsl libjpeg-turbo python r gcc-toolchain libice))
    (native-inputs (list coreutils libx11 libxft libxp tcsh libpng netpbm openblas libxml2 gsl libjpeg-turbo python r gcc-toolchain libice))
    (build-system gnu-build-system)
    (arguments
     (list
      #:make-flags '(list "install")
      #:phases
       '(modify-phases %standard-phases
          (add-after 'unpack 'add-makefile
            (lambda* (#:key outputs #:allow-other-keys)
              (invoke "sh" "-c"
                      "echo -e true >> configure; chmod +x configure")
              (invoke "sh" "-c"
                      "echo -e 'install:\n\tPREFIX=$PWD/bin make -C src -f Makefile.linux_openmp_64 vastness' >> Makefile")
              )))))
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
))

afni
