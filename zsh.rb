class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.8/zsh-5.8.tar.xz"
  mirror "https://www.zsh.org/pub/zsh-5.8.tar.xz"
  sha256 "dcc4b54cc5565670a65581760261c163d720991f0d06486da61f8d839b52de27"
  revision 2

  head do
    url "https://git.code.sf.net/p/zsh/code.git"
    depends_on "autoconf" => :build
  end

  bottle :unneeded

  depends_on "texinfo" => :build if OS.linux?
  depends_on "ncurses"
  depends_on "pcre"

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/neovim/releases/download/unicode%2F13.0.0/wcwidth9.h"
    sha256 "e4cfc677b500877d32c3df2bab39324ea5a8422a93c4e19d3214f547de6a5c22"
  end

  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.8/zsh-5.8-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.8-doc.tar.xz"
    sha256 "9b4e939593cb5a76564d2be2e2bfbb6242509c0c56fd9ba52f5dba6cf06fdcc4"
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
