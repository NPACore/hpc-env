(define-module (gnu packages kwstyle)
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

kwstyle
