(use-modules
 (gnu packages algebra)
 (gnu packages check)
 (gnu packages commencement)
 (gnu packages compression)
 (gnu packages image)
 (gnu packages base)
 (gnu packages shells) ;tcsh
 (gnu packages xml) ; xpat
 (guix build-system gnu)
 (guix build-system cmake)
 (guix git-download)
 ((guix licenses) #:prefix license:)
 (guix packages))

;; copy of image/niftilib. some updates since what was packaged (2.0)
(define-public niftilib
  (package
    (name "niftilib")
    (version "3.0.1.20230911") ; 75180f776997bd161c5b231dfffb65e6385f5f93
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/NIFTI-Imaging/nifti_clib")
             (commit "75180f776997bd161c5b231dfffb65e6385f5f93")
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1kb7ys5278vadiln1w9ssff1jmx33zbg6h36m8kkiqdjspqw4q8g"))))
    (build-system cmake-build-system)
    (arguments (list
                #:configure-flags
                '(list "-DBUILD_SHARED_LIBS=ON" "-DDOWNLOAD_TEST_DATA=OFF")
                #:tests? #f
 ))
    (inputs (list zlib))
    (synopsis "Library for reading and writing files in the nifti-1 format")
    (description "Niftilib is a set of i/o libraries for reading and writing
files in the nifti-1 data format - a binary file format for storing
medical image data, e.g. magnetic resonance image (MRI) and functional MRI
(fMRI) brain images.")
    (home-page "https://github.com/NIFTI-Imaging/nifti_clib")
    (license license:public-domain)))

niftilib
