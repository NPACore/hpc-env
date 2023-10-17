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
(include "nifticlib.scm")
(define-public giftilib
  (package
    (version "git")
    (name"giftilib")
    (synopsis "Geometry format under the Neuroimaging Informatics Technology Initiative (NIfTI).")
    (home-page #f)
    (description "Geometry format under the Neuroimaging Informatics Technology Initiative.")
    (build-system cmake-build-system)
    (arguments (list
                ;#:make-flags '(list  )
                #:configure-flags
                '(list "-DBUILD_TESTING=OFF"
                       "-DUSE_SYSTEM_NIFTI=ON" "-DDOWNLOAD_TEST_DATA=OFF"
                       ;(string-append "-DNIFTI_DIR=" (assoc-ref %build-inputs "niftilib") "/include")
                       )
                #:tests? #f
                ;#:phases '(modify-phases %standard-phases
                ;            (add-before 'configure 'set-nifti-dir (lambda _
                ;              (setenv "NIFTI_DIR" (string-append (assoc-ref %build-inputs "niftilib") "/share/cmake"))
                ;              (display (getenv "NIFTI_DIR")))))
                ))
    (license #f)
    (inputs (list tcsh))
    ;(native-inputs (list tcsh zlib expat niftilib))
    (native-inputs `(("tcsh" ,tcsh)
                     ("zlib" ,zlib)
                     ("expat" ,expat)
                     ("niftilib" ,niftilib)))
    (source (origin
              (method git-fetch)
              (uri (git-reference (url "https://github.com/NIFTI-Imaging/gifti_clib.git")
                                  (commit "5eae81ba1e87ef3553df3b6ba585f12dc81a0030")))
              (sha256 (base32 "0gcab06gm0irjnlrkpszzd4wr8z0fi7gx8f7966gywdp2jlxzw19")))))
  )

giftilib
