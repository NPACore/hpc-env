;https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_linux_ubuntu22.html
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
 (gnu packages shells)
 (gnu packages netpbm)
 (gnu packages xml)
 (gnu packages xorg)
 (guix build-system copy)
 (guix download)
 ((guix licenses) #:prefix license:)
 (guix packages))

(define-public afni
  (package
    (name "afni")
    (version "3.22") ;   5 May 2023, fetched 2023-10-14
    (home-page "https://afni.nimh.nih.gov")
    (license #f) ; gpl3?
    (synopsis "Analysis of Functional NeuroImages")
    (description "Analysis of Functional NeuroImages is a leading software suite of C, Python, R programs and shell scripts primarily developed for the analysis and display of multiple MRI modalities: anatomical, functional MRI (FMRI) and diffusion weighted (DW) data. ")

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
    (inputs (list libx11 libxft libxp tcsh libpng netpbm openblas libxml2 gsl libjpeg-turbo python r gcc-toolchain libice))
    (native-inputs (list libx11 libxft libxp tcsh libpng netpbm openblas libxml2 gsl libjpeg-turbo python r gcc-toolchain libice))
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


    (source (origin
               (method url-fetch)
               (uri (string-append "https://afni.nimh.nih.gov/pub/dist/tgz/linux_openmp_64.tgz"))
               (sha256
                (base32
                 "1ngwy02h75j7yb4lkkjiah42q6a36r8j2ay49nssvqfzmk5q9f8c"))))
    ; tar -zvtf /gnu/store/c10j7r0v4ma1h2gbhvlx8s0xdsb16f6p-linux_openmp_64.tgz|sed 2q
    ;  drwxr-xr-x afniHQ/users      0 2023-10-12 18:09 linux_openmp_64/
    ;  -rwxr-xr-x afniHQ/users   4414 2023-10-12 18:08 linux_openmp_64/@afni.run.me
    (build-system copy-build-system)
    (arguments
     ; guix already inside only directory of tarball
     '(#:install-plan '(("./" "bin/"))))))

afni
