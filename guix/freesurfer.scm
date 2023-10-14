; https://surfer.nmr.mgh.harvard.edu/fswiki/BuildGuide
;git clone git@github.com:freesurfer/freesurfer.git
; fs-7.4.1
(define-module (gnu packages freesurfer)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages compression) ; unzip
  #:use-module (gnu packages perl)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages vim) ;xxd
  #:use-module (gnu packages python)
  #:use-module (gnu packages shells) ;tcsh tcl
  #:use-module (gnu packages maths) ;netcdf
  #:use-module (gnu packages gl) ;glew
  #:use-module (gnu packages tcl)
  #:use-module (gnu packages graphics) ;vtk opecv
  #:use-module (gnu packages image-processing) ;insight-toolkit (itk)
  #:use-module (guix build-system cmake)
)


(define-public freesurfer
   (package
     (name "freesurfer")
     (version "7.4.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/freesurfer/freesurfer")
             (commit (string-append "fs-" version))
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1kqgy835rdmmhx7v7b3kkrf1wfkbm26fgks1nf3r5fnqvkiw93z8"))))
    (native-inputs (list perl gfortran python tcl xxd opencv vtk zlib insight-toolkit netcdf tcsh glew))
     (inputs (list perl)) ;R
     (build-system cmake-build-system)
     ; https://surfer.nmr.mgh.harvard.edu/fswiki/BuildRequirements
     (arguments '(#:configure-flags '("-DBUILD_GUIS=OFF")))

     (synopsis "freesurfer")
     (description "FS")
     (home-page "https://surfer.nmr.mgh.harvard.edu/")
     (license asl2.0))) ; TODO: fix

freesurfer
