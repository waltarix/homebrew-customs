class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"

  stable do
    url "https://downloads.sourceforge.net/project/zsh/zsh/5.3.1/zsh-5.3.1.tar.gz"
    mirror "https://www.zsh.org/pub/zsh-5.3.1.tar.gz"
    sha256 "3d94a590ff3c562ecf387da78ac356d6bea79b050a9ef81e3ecb9f8ee513040e"

    # We cannot build HTML doc on HEAD, because yodl which is required for
    # building zsh.texi is not available.
    option "with-texi2html", "Build HTML documentation"
    depends_on "texi2html" => [:build, :optional]
  end

  bottle do
    sha256 "054988ed570c911f1758f08b71777707154101b180570577d1d4a4380043a041" => :sierra
    sha256 "8fb846fbfb27744a50b4e5cff2767f6fca49016f356bd6273dedfc8e2abdd919" => :el_capitan
    sha256 "4ca1f10d588cedb061826c6a6aa0bbde233627cf86188deed0bd07321f91d739" => :yosemite
  end

  def pour_bottle?
    false
  end

  head do
    url "git://git.code.sf.net/p/zsh/code"
    depends_on "autoconf" => :build

    option "with-unicode9", "Build with Unicode 9 character width support"
  end

  option "without-etcdir", "Disable the reading of Zsh rc files in /etc"
  option "with-unicode9", "Build with Unicode 9 character width support"

  deprecated_option "disable-etcdir" => "without-etcdir"

  depends_on "gdbm"
  depends_on "pcre"
  depends_on "ncurses"
  depends_on "waltarix/customs/wcwidth-cjk"

  def install
    ncurses = Formula["ncurses"]
    wcwidth = Formula["wcwidth-cjk"]

    ENV.append "LDFLAGS", "-L#{ncurses.lib}"
    ENV.append "LDFLAGS", "-L#{wcwidth.lib} -lwcwidth-cjk"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}"

    system "Util/preconfig" if build.head?

    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{pkgshare}/functions
      --enable-scriptdir=#{pkgshare}/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-runhelpdir=#{pkgshare}/help
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
      --enable-locale
      --with-term-lib=ncursesw
    ]

    args << "--enable-unicode9" if build.with? "unicode9"

    if build.without? "etcdir"
      args << "--disable-etcdir"
    else
      args << "--enable-etcdir=/etc"
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    if build.head?
      # disable target install.man, because the required yodl comes neither with macOS nor Homebrew
      # also disable install.runhelp and install.info because they would also fail or have no effect
      system "make", "install.bin", "install.modules", "install.fns"
    else
      system "make", "install"
      system "make", "install.info"
      system "make", "install.html" if build.with? "texi2html"
    end
  end

  def caveats; <<-EOS.undent
    In order to use this build of zsh as your login shell,
    it must be added to /etc/shells.
    EOS
  end

  test do
    assert_equal "homebrew\n",
      shell_output("#{bin}/zsh -c 'echo homebrew'")
  end
end
