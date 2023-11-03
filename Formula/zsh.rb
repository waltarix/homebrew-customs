class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.9/zsh-5.9.tar.xz"
  mirror "https://www.zsh.org/pub/zsh-5.9.tar.xz"
  sha256 "9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5"
  license "MIT-Modern-Variant"
  revision 4

  livecheck do
    url "https://sourceforge.net/projects/zsh/rss?path=/zsh"
  end

  head do
    url "https://git.code.sf.net/p/zsh/code.git", branch: "master"
    depends_on "autoconf" => :build
  end

  depends_on "ncurses"
  depends_on "pcre2"

  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.9/zsh-5.9-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.9-doc.tar.xz"
    sha256 "6f7c091249575e68c177c5e8d5c3e9705660d0d3ca1647aea365fd00a0bd3e8a"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.1.0-r1/wcwidth9.h"
    sha256 "5afe09e6986233b517c05e4c82dbb228bb6ed64ba4be6fd7bf3185b7d3e72eb0"
  end

  patch do
    url "https://deb.debian.org/debian/pool/main/z/zsh/zsh_5.9-5.debian.tar.xz"
    sha256 "f7ca24eb97ab9fbd9dad26b1e5f7eb863b621d11893bb6f2d87b269d0e6db581"
    apply %w[
      patches/further-mitigate-test-suite-hangs.patch
      patches/update-debian-sections.patch
      patches/use-pager-instead-of-more-by-default.patch
      patches/fix-typos-in-man-pages.patch
      patches/cherry-pick-3e3cfabc-revert-38150-and-fix-in-calling-function-cfp_matcher_range-instead.patch
      patches/cherry-pick-4b7a9fd0-additional-typset--p--m-fix-for-namespaces.patch
      patches/cherry-pick-b62e91134-51723-migrate-pcre-module-to-pcre2.patch
      patches/cherry-pick-10bdbd8b-51877-do-not-build-pcre-module-if-pcre2-config-is-not-found.patch
    ]
  end

  def install
    resource("wcwidth9.h").stage(buildpath/"Src")

    Formula["ncurses"].tap do |ncurses|
      ENV.append_to_cflags "-I#{ncurses.include}"
      ENV.append "LDFLAGS", "-L#{ncurses.lib}"
    end

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append_to_cflags "-flto"
    ENV.append_to_cflags "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    # Fix compile with newer Clang
    # https://www.zsh.org/mla/workers/2020/index.html
    # https://github.com/Homebrew/homebrew-core/issues/64921
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1200

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
           "--enable-readnullcmd=pager",
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
      system "make"
      system "make", "install"

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
