;; Malte Frank Gerdes on Tue, 07 Feb 2023 04:20:41 -0800
;; 20231014 pulled from https://www.mail-archive.com/freesurfer@nmr.mgh.harvard.edu/msg74330.html
;; using imagag-processing:insight-toolkit instead of prev included "itk", bump version to 7.4
(use-modules
 (gnu packages algebra)
 (gnu packages check)
 (gnu packages commencement)
 (gnu packages compression)
 (gnu packages fontutils)
 (gnu packages geo)
 (gnu packages gl)
 (gnu packages image)
 (gnu packages image-processing)
 (gnu packages llvm)
 (gnu packages maths)
 (gnu packages pdf)
 (gnu packages perl)
 (gnu packages python)
 (gnu packages qt)
 (gnu packages serialization)
 (gnu packages shells)
 (gnu packages sqlite)
 (gnu packages tcl)
 (gnu packages vim)
 (gnu packages xiph)
 (gnu packages xml)
 (gnu packages xorg)
 (guix build-system cmake)
 (guix download)
 (guix gexp)
 (guix git-download)
 ((guix licenses) #:prefix license:)
 (guix packages))

(define-public freesurfer
  (package
    (name "freesurfer")
    ;(version "7.3.3")
    (version "7.4.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/freesurfer/freesurfer/")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1vn9vs6q451qp8ak62fc21zv91gm2f0f5wiijh4xj4zys3fyvi93"))
              (modules '((guix build utils)))
              (snippet '(begin
                          (substitute* "CMakeLists.txt"
                            (("ARMADILLO") "Armadillo")
                            (("OPENGL") "OpenGL"))
                          (substitute* "cmake/FindOpenCV.cmake"
                            (("opencv2 PATH_SUFFIXES include")
                             "opencv2 opencv4/opencv2 PATH_SUFFIXES include"))))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags
       (list "-DMARTINOS_BUILD=OFF"
             "-DBUILD_GUIS=OFF")))
    (native-inputs
     `(("gfortran-toolchain" ,gfortran-toolchain)
       ("gl2ps" ,gl2ps)
       ("googletest" ,(package-source googletest))
       ("perl" ,perl)
       ("python" ,python)
       ("tcl" ,tcl)
       ("tcsh" ,tcsh)
       ("xxd" ,xxd)))
    (inputs (list armadillo
                  openblas
                  double-conversion
                  eigen
                  expat
                  freetype
                  hdf5
                  glew
                  insight-toolkit
                  jsoncpp
                  lapack
                  libharu
                  libjpeg-turbo
                  libpng
                  libtheora
                  libtiff
                  libx11
                  libxt
                  libxml2
                  libxmu
                  lz4
                  mesa
                  netcdf
                  opencv
                  petsc
                  proj
                  qtbase-5
                  qtx11extras
                  sqlite
                  vtk
                  zlib))
    (outputs (list "out" "debug"))
    (synopsis "Software suite for processing human brain MRI")
    (description
     "FreeSurfer is a software package for the analysis and visualization of
neuroimaging data from cross-sectional and longitudinal studies.  It is
developed by the Laboratory for Computational Neuroimaging at the Martinos
Center for Biomedical Imaging.
FreeSurfer provides full processing streams for structural and functional MRI
and includes tools for linear and nonlinear registration, cortical and
subcortical segmentation, cortical surface reconstruction, statistical analysis
of group morphometry, diffusion MRI, PET analysis, and much more.  It is also
the structural MRI analysis software of choice for the Human Connectome
Project.")
    (home-page "https://surfer.nmr.mgh.harvard.edu")
    ;; it's an open source license but afaict it isn't free as in freedom.
    (license #f)))

freesurfer
