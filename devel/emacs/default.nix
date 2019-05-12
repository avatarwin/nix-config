{
  pkgs ? import <nixpkgs> {},
  pkgconfig ? pkgs.pkgconfig,
  stdenv ? pkgs.stdenv,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  libXaw ? pkgs.xorg.libXaw,
  libXpm ? pkgs.xorg.libXpm,
  libXft ? pkgs.xorg.libXft,
  libXcursor ? pkgs.xorg.libXcursor,
  siteStart ? ./site-start.el
}:

with pkgs; stdenv.mkDerivation rec {
  name = "emacsHEAD";
  version = "27.0.50";
  versionModifier = "";
  toolkit = "lucid";

  src = fetchFromGitHub {
    owner = "emacs-mirror";
    repo = "emacs";
    rev = "40b3dcb7f7be92f0471e7a503ae8598c72100146";
    ## As of Sat 11 May 18:59:18 UTC 2019
    sha256 = "0501wj6r5ccljdwgsf2i4y0x1hy4clbck5vp5kxqhaaygd06fdvh";
  };

  configureFlags = [
    "--disable-build-details"
    "--with-modules"
    "--with-x-toolkit=lucid"
  ];
  nativeBuildInputs = [ pkgconfig autoconf automake texinfo ];
  buildInputs = [
    autoconf
    autogen
    automake
    gnutls
    acl
    gettext
    libXcursor
    libxml2
    libXaw
    libXpm
    libjpeg
    libpng
    xlibsWrapper
    libungif
    libtiff
    librsvg
    libXft
    dbus
    libotf
    ncurses
    fontconfig
  ];

  preConfigure = ''
    ./autogen.sh

    for makefile_in in $(find . -name Makefile.in -print); do
        substituteInPlace $makefile_in --replace /bin/pwd pwd
    done
  '';

  installTargets = "tags install";

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp
    cp ${siteStart} $out/share/emacs/site-lisp/site-start.el
    $out/bin/emacs --batch -f batch-byte-compile $out/share/emacs/site-lisp/site-start.el

    rm -rf $out/var
    rm -rf $out/share/emacs/${version}/site-lisp
  '';

  postFixup =
    let libPath = lib.makeLibraryPath [
      libXcursor
    ];
    in ''
      patchelf --set-rpath \
        "$(patchelf --print-rpath "$out/bin/emacs"):${libPath}" \
        "$out/bin/emacs"
      patchelf --add-needed "libXcursor.so.1" "$out/bin/emacs"
    '';

  meta = with stdenv.lib; {
    description = "The extensible, customizable GNU text editor";
    homepage    = https://www.gnu.org/software/emacs/;
    license     = licenses.gpl3Plus;
    maintainers = with maintainers; [ lovek323 peti the-kenny jwiegley ];
    platforms   = platforms.all;

    longDescription = ''
      GNU Emacs is an extensible, customizable text editor—and more.  At its
      core is an interpreter for Emacs Lisp, a dialect of the Lisp
      programming language with extensions to support text editing.

      The features of GNU Emacs include: content-sensitive editing modes,
      including syntax coloring, for a wide variety of file types including
      plain text, source code, and HTML; complete built-in documentation,
      including a tutorial for new users; full Unicode support for nearly all
      human languages and their scripts; highly customizable, using Emacs
      Lisp code or a graphical interface; a large number of extensions that
      add other functionality, including a project planner, mail and news
      reader, debugger interface, calendar, and more.  Many of these
      extensions are distributed with GNU Emacs; others are available
      separately.
    '';
  };

}
