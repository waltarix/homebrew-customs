class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.7.1/zsh-5.7.1.tar.xz"
  mirror "https://www.zsh.org/pub/zsh-5.7.1.tar.xz"
  sha256 "7260292c2c1d483b2d50febfa5055176bd512b32a8833b116177bf5f01e77ee8"

  bottle do
    sha256 "793d87f67e64a5e01dfdea890af218e4779a2df514d395b956e464129af16fd7" => :mojave
    sha256 "6656fe9aa5d5cbaff49bc9c1ccf17b7d96d21036ac44c9181bd35c57dc38b450" => :high_sierra
    sha256 "008dfc844b88fcd61925233b08f0d78b2851bf2901320a5f6ee975da4b8604e3" => :sierra
  end

  head do
    url "https://git.code.sf.net/p/zsh/code.git"
    depends_on "autoconf" => :build
  end

  def pour_bottle?
    false
  end

  depends_on "texinfo" => :build if OS.linux?
  depends_on "ncurses"
  depends_on "pcre"

  resource "wcwidth9.h" do
    url "https://gist.githubusercontent.com/waltarix/7a36cc9f234a4a2958a24927696cf87c/raw/d4a38bc596f798b0344d06e9c831677f194d8148/wcwidth9.h"
    sha256 "50b5f30757ed9e1f9bece87dec4d70e32eee780f42b558242e4e76b1f9b334c8"
  end

  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.7.1/zsh-5.7.1-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.7.1-doc.tar.xz"
    sha256 "3053670250e23905c940592c79428d7f67495fa05b0fff49dfaab9172c4239b4"
  end

  def install
    (buildpath/"Src").install resource("wcwidth9.h")

    ncurses = Formula["ncurses"]

    ENV.append "LDFLAGS", "-L#{ncurses.lib}"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}"

    system "Util/preconfig" if build.head?

    system "./configure", "--prefix=#{prefix}",
                          "--enable-fndir=#{pkgshare}/functions",
                          "--enable-scriptdir=#{pkgshare}/scripts",
                          "--enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions",
                          "--enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts",
                          "--enable-runhelpdir=#{pkgshare}/help",
                          "--enable-cap",
                          "--enable-maildir-support",
                          "--enable-multibyte",
                          "--enable-pcre",
                          "--enable-zsh-secure-free",
                          "--enable-unicode9",
                          "--enable-etcdir=/etc",
                          "--with-tcsetpgrp",
                          "--with-term-lib=ncursesw",
                          "DL_EXT=bundle"

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

      resource("htmldoc").stage do
        (pkgshare/"htmldoc").install Dir["Doc/*.html"]
      end
    end
  end

  test do
    assert_equal "homebrew", shell_output("#{bin}/zsh -c 'echo homebrew'").chomp
    system bin/"zsh", "-c", "printf -v hello -- '%s'"
  end
end
