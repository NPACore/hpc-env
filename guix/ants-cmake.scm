(define-module (gnu packages neuroimaging)
  #:use-module ((guix licenses) #:prefix license:) ; conflicts with unzip use license:*
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
  #:use-module (gnu packages maths) ; hdf5 (itk)
  #:use-module (gnu packages algebra) ; fftwf (itk)
  #:use-module (gnu packages image) ; libpng (itk)
  #:use-module (gnu packages gl) ; mesa-opencl (itk)
  #:use-module (gnu packages xml) ; expat (itk)
  #:use-module (gnu packages python) ; (itk)
  #:use-module (gnu packages tbb) ; (itk)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages image-processing)
)

(define-public kwstyle
  (package
    (name "kwstyle")
    (version "2021.10.08")
    (home-page "https://github.com/InsightSoftwareConsortium/ITK/")
    (synopsis "style checker for source code")
    (license license:asl2.0)
    (description "WStyle is integrated in the software process to ensure that the code written by several users is consistent and can be viewed/printed as it was written by one person.")
    (build-system cmake-build-system)
    (native-inputs (list pkg-config))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Kitware/KWStyle")
             (commit "1173206c0e7f4bc70dc3af641daf6e33f4042772")
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0g1idakq8h3nm8904jg9v8hmi07jw1acdjw3hyga6h0w9vvslmll")))
     )))

(define-public insight-toolkit
  (package
    (name "insight-toolkit")
    (version "5.4") ; 5.4rc02
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/InsightSoftwareConsortium/ITK/")
             ; this is what's in ANTs SuperBuild/External_ITKv5.cmake
             (commit "fabc102c520bcbd21ea35e7303e3756c223e10d7"; (string-append "v" version)
                     )
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "04rq674mzav8daadqzk2ir3qi4l91h4k617hs7gqn41yszj5c93w")))
    )
    (build-system cmake-build-system)
    (arguments
     (list #:tests? #f ; tests require network access and external data
           #:configure-flags '(list "-DITK_USE_GPU=ON"
                                 "-DITK_USE_SYSTEM_LIBRARIES=ON"
                                 "-DITK_USE_SYSTEM_GOOGLETEST=ON"
                                 "-DITK_BUILD_SHARED=ON"
                                 ;; disabe fetching KWStyle, example data
                                 "-DITK_FORBID_DOWNLOADS=ON"
                                 "-DBUILD_TESTING=OFF"
                                 ;; This prevents "GTest::GTest" from being added to the ITK_LIBRARIES
                                 ;; variable in the installed CMake files.  This is necessary as other
                                 ;; packages using insight-toolkit could not be configured otherwise.
                                 "-DGTEST_ROOT=gtest"
                                 "-DCMAKE_CXX_STANDARD=17"
                                 ; from https://github.com/ANTsX/ANTs/blob/master/SuperBuild/External_ITKv5.cmake
                                 "-DITK_LEGACY_REMOVE:BOOL=OFF"
                                 "-DITK_BUILD_DEFAULT_MODULES:BOOL=ON"
                                 "-DKWSYS_USE_MD5:BOOL=ON" ; Required by SlicerExecutionModel
                                 "-DITK_WRAPPING:BOOL=OFF"
                                 "-DITKZLIB:BOOL=ON"
                                 "-DModule_MGHIO:BOOL=ON"
                                 "-DModule_ITKReview:BOOL=ON"
                                 "-DModule_GenericLabelInterpolator:BOOL=ON"
                                 "-DModule_AdaptiveDenoising:BOOL=ON"
)

           #:phases '(modify-phases %standard-phases
                        (add-after 'unpack 'do-not-tune
                          (lambda _
                            (substitute* "CMake/ITKSetStandardCompilerFlags.cmake"
                              (("-mtune=native")
                               "")))))))
    (inputs
     (list eigen
           expat
           fftw
           fftwf
           hdf5
           libjpeg-turbo
           libpng
           libtiff
           mesa-opencl
           perl
           python
           tbb
           vxl-1
           zlib))
    (native-inputs
     (list git kwstyle googletest pkg-config))

    ;; The 'CMake/ITKSetStandardCompilerFlags.cmake' file normally sets
    ;; '-mtune=native -march=corei7', suggesting there's something to be
    ;; gained from CPU-specific optimizations.
    (properties '((tunable? . #t)))

    (home-page "https://github.com/InsightSoftwareConsortium/ITK/")
    (synopsis "Scientific image processing, segmentation and registration")
    (description "The Insight Toolkit (ITK) is a toolkit for N-dimensional
scientific image processing, segmentation, and registration.  Segmentation is
the process of identifying and classifying data found in a digitally sampled
representation.  Typically the sampled representation is an image acquired
from such medical instrumentation as CT or MRI scanners.  Registration is the
task of aligning or developing correspondences between data.  For example, in
the medical environment, a CT scan may be aligned with a MRI scan in order to
combine the information contained in both.")
    (license license:asl2.0)
))

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
    (native-inputs (list perl git hdf5 insight-toolkit googletest pkg-config cmake))
    (inputs (list perl)) ;R
    (build-system cmake-build-system)
    ; find_package(GTest REQUIRED)
    (arguments
     (list
      #:build-type "Release"
      #:configure-flags '(list
                          "-DUSE_SYSTEM_ITK=ON" "-DBUILD_EXAMPLES=OFF" "-DBUILD_TESTING=OFF"
"-DRUN_SHORT_TESTS=OFF" "-DRUN_LONG_TESTS=OFF")
      #:phases
      '(modify-phases %standard-phases
          (add-after 'unpack 'cmake-add-gtest
            (lambda* (#:key outputs #:allow-other-keys)
            (invoke "sh" "-c" "echo -e 'find_package(GTest REQUIRED)' >> ANTS.cmake")
            (invoke "sh" "-c" "echo -e 'find_package(GTest REQUIRED)' >> Examples/CMakeLists.txt")))
            ;;remove Examples to exclude tests, but still need to be able to find GTest
            ;(lambda* (#:key inputs #:allow-other-keys)
            ;  (substitute* "ANTS.cmake" ;"Examples/CMakeLists.txt"
            ;    (("add_subdirectory\\(Examples\\)")
            ;     "find_package(GTest REQUIRED)"))
            ;  ))
          ; root level makefile doesn't have install rule. it's inside ANTS-build
          (add-before 'install 'make-ants
            (lambda* (#:key outputs #:allow-other-keys)
               (invoke "sh" "-c" "echo -e 'install:\n\tmake -C ANTS-build/ install' >> Makefile")
               ;(error)
              ))
)

      ;error: in phase 'install': uncaught exception:
      ;%exception #<&invoke-error program: "make" arguments: ("install") exit-status: 2 term-signal: #f stop-signal: #f>
      ;need to be in 'ANTs/' to run install?
      ))
    (synopsis "Advanced Normalization Tools (ANTs)")
    (description "ANTs computes high-dimensional mappings to capture the statistics of brain structure and function.")
    (home-page "https://github.com/ANTsX/ANTs")
    (license license:asl2.0))) ; Apache-2.0 license

ants