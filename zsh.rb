class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.7/zsh-5.7.tar.xz"
  mirror "https://www.zsh.org/pub/zsh-5.7.tar.xz"
  sha256 "7807b290b361d9fa1e4c2dfafc78cb7e976e7015652e235889c6eff7468bd613"
  revision 1

  bottle do
    sha256 "704757d9e92b55847dfc1442461121ff03efeeeb80a1ac3e81ed60cf04a20444" => :mojave
    sha256 "a2b87d988cdb6cc1459c8e1886c2d33ce9f5c17acd6198b5752574fee7b9ea1b" => :high_sierra
    sha256 "4497077b11c9ff6499f8b6104f688520cda11adcf4fd36f170e39cdde5919979" => :sierra
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
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.7/zsh-5.7-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.7-doc.tar.xz"
    sha256 "f0a94db78ef8914743da49970c00fe867e0e5377fbccd099afe55d81a2d7f15d"
  end

  # Upstream patch to fix broken VCS_INFO, remove when next release is out
  # See https://www.zsh.org/mla/workers/2019/msg00058.html
  patch do
    url "https://github.com/zsh-users/zsh/commit/b70919e0d9dadc93893e9d18bc3ef13b88756ecf.diff?full_index=1"
    sha256 "9025a88631a13c9eac3d66cae339833f91c015ff1c8319cd6f4f002a99f27f9c"
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
