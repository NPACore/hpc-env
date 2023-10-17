(use-modules
 (gnu packages check)
 (gnu packages commencement)
 (gnu packages lesstif) ;motif
 (gnu packages xorg) ; libx11 libXmu
 (gnu packages image) ; libjpeg-turbo
 (gnu packages fontutils) ; freetype
 ((guix licenses) #:prefix license:)
 (guix build-system gnu)
 (guix build gnu-build-system)
 (guix build utils)
 (guix download)
 (guix packages))

(define-public xmhtml
(package
  (version "1.1.10")
  (name "XmHTML")
  (description "a HTML widget for Motif")
  (synopsis "XmHTML is primarily useful for displaying help texts or to visualize results of computations in an application.")
  (license #f)
  (home-page "https://sourceforge.net/projects/xmhtml/")
  (native-inputs (list libx11 motif libxmu libjpeg-turbo freetype))
  (build-system gnu-build-system)
  (arguments '(
#:phases
                   (modify-phases %standard-phases (delete 'bootstrap) (delete 'configure) (delete 'check))))
  (source (origin
               (method url-fetch)
               (uri (string-append "https://master.dl.sourceforge.net/project/xmhtml/XmHTML-1.1.10.tgz"))
               (sha256 (base32 "0d84zvp2s9g7sh9crgfn00jwh5g26d4g8mcrlihhmmsqk5i4559p"))))
))
xmhtml
