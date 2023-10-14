(define-module (gnu packages ants)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages base) ; glibc
  #:use-module (gnu packages gcc) ; libstdc++
  #:use-module (gnu packages commencement) ;canonical-package
  ;#:use-module (guix build-syste m r)
)


(define-public ants
   (package
    (name "ants")
    (version "2.5.0")
    (source (origin
              (method url-fetch)
              ;https://github.com /ANTsX/ANTs/releases/download/v2.5.0/ants-2.5.0-ubuntu-22.04-X64-gcc.zip
              (uri (string-append  "https://github.com/ANTsX/ANTs/releases/download/v" version
                                  "/" name "-" version "-ubuntu-20.04-X64-gcc.zip"))
       ;/gnu/store/xybgsg5ssqfpmpnmsmvajmhxdc6bmg82-ants-2.5.0-ubuntu-22.04-X64-gcc.zip
              (sha256
               (base32
                "1aa8x16piij4mzgavbgk9xbkilbd9x0d6lcyapm6k17l34d4yrym"))))
                ;"11j03q4zs95ghmwd7pdli9l5s3z04vvwfz2m0lgvp6628z1n0hld"))))

    (native-inputs (list perl unzip))
    ;(inputs `(("perl" ,perl) ("gcc:lib" ,(canonical-package gcc) "lib")))
    (inputs (list perl (make-libstdc++ gcc)))
     (build-system copy-build-system)
     (arguments '(#:install-plan '(("bin/" "bin/") ("lib/" "lib/"))))
     (synopsis "Advanced Normalization Tools (ANTs)")
     (description "ANTs computes high-dimensional mappings to capture the statistics of brain structure and function.")
     (home-page "https://github.com/ANTsX/ANTs")
     (license asl2.0))) ; Apache-2.0 license

ants
