(define-module (gnu packages ants)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages compression) ; unzip
  #:use-module (gnu packages perl)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages check) ; googletest (GTest::* in cmake)
  #:use-module (gnu packages certs) ;nss-certs
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages image-processing)
)


(define-public ants
   (package
     (name "ants")
     (version "2.5.0")
     ;(itk-version "5.4rc02")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ANTsX/ANTs")
             (commit (string-append "v" version))
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0i67j4alsrrs1xi61sr7zwnhyr6z5v53g6fbmasw113br9r9na5d")))
    )
    (native-inputs (list perl git insight-toolkit googletest pkg-config cmake))
    (inputs (list perl)) ;R
    (build-system cmake-build-system)
    ; find_package(GTest REQUIRED)
    (arguments
     (list
      #:build-type "Release"
      #:configure-flags '(list "-DUSE_SYSTEM_ITK=ON" "-DBUILD_EXAMPLES=OFF")
      #:phases
      '(modify-phases %standard-phases
          ; remove Examples to exclude tests, but still need to be able to find GTest
          (add-after 'unpack 'patch-source
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "ANTS.cmake"
                (("add_subdirectory\\(Examples\\)")
                 "find_package(GTest REQUIRED)"))
              ))
          ; root level makefile doesn't have install rule. it's inside ANTS-build
          (add-before 'install 'make-ants
            (lambda* (#:key outputs #:allow-other-keys)
               (invoke "sh" "-c" "echo -e 'install:\n\tmake -C ANTS-build/ install' >> Makefile")
              ))
)

      ;error: in phase 'install': uncaught exception:
      ;%exception #<&invoke-error program: "make" arguments: ("install") exit-status: 2 term-signal: #f stop-signal: #f>
      ;need to be in 'ANTs/' to run install?
      ))
    (synopsis "Advanced Normalization Tools (ANTs)")
    (description "ANTs computes high-dimensional mappings to capture the statistics of brain structure and function.")
    (home-page "https://github.com/ANTsX/ANTs")
    (license asl2.0))) ; Apache-2.0 license

ants
