(define-module (gnu packages insight-toolkit)
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
    (version "5.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/InsightSoftwareConsortium/ITK/")
             ;5.4.rc02  (commit (string-append "v" version)) "04rq674mzav8daadqzk2ir3qi4l91h4k617hs7gqn41yszj5c93w"
             (commit "fabc102c520bcbd21ea35e7303e3756c223e10d7")
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0qqmd1sb741p1bizklc3axpcrlb67l754fjrm48z71k1064hhc0c"))))
    (build-system cmake-build-system)
    (arguments
     (list #:tests? #f ; tests require network access and external data
           #:configure-flags '(list "-DITK_USE_GPU=ON"
                                 "-DITK_USE_SYSTEM_LIBRARIES=ON"
                                 "-DITK_USE_SYSTEM_GOOGLETEST=ON"
                                 "-DITK_BUILD_SHARED=ON"
                                 ;; KWStyle and ITK (insight-toolbox) need to be built elsewhere
                                 "-DITK_FORBID_DOWNLOADS=ON"
                                 "-DBUILD_TESTING=OFF"
                                 ;; This prevents "GTest::GTest" from being added to the ITK_LIBRARIES
                                 ;; variable in the installed CMake files.  This is necessary as other
                                 ;; packages using insight-toolkit could not be configured otherwise.
                                 "-DGTEST_ROOT=gtest"
                                 "-DCMAKE_CXX_STANDARD=17"
                                 ; from https://github.com/ANTsX/ANTs/blob/master/SuperBuild/External_ITKv5.cmake
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
                               ""))))

                        ; ModuleExternal needed by itk-gli but not copied in
                        ; NB. hard coced ITK-5.4
                        (add-after 'install 'copy-cmake
                          (lambda* (#:key outputs #:allow-other-keys)
                            (install-file "CMake/ITKModuleExternal.cmake" (string-append (assoc-ref outputs "out") "/lib/cmake/ITK-5.4/"))
                                          )))))
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

insight-toolkit

(define-public itk-gli
  (package
    (name "itk-gli")
    (version "5.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/InsightSoftwareConsortium/ITKGenericLabelInterpolator")
             ;5.4.rc02  (commit (string-append "v" version)) "04rq674mzav8daadqzk2ir3qi4l91h4k617hs7gqn41yszj5c93w"
             (commit "35212939091e9a449e78cf4b811f8081e2d3f104")
             (recursive? #t)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0bz8rxlvkmm9l7d9riqbyfnygss5i7aidw21ffk29zbjc3w9qi4y"))))
    (build-system cmake-build-system)
    (inputs
     (list eigen
           fftw
           fftwf
           hdf5
           perl
           python
           zlib))
    (native-inputs (list insight-toolkit googletest pkg-config))
    (properties '((tunable? . #t)))
    (home-page "https://github.com/InsightSoftwareConsortium/ITKGenericLabelInterpolator")
    (synopsis "Insight Toolkit (ITK) generic interpolator module")
    (description "A module for the Insight Toolkit (ITK) that provides a generic interpolator for label images to interpolate each label with an ordinary image interpolator, and return the label with the highest value.")
    (license license:asl2.0)
))
itk-gli
