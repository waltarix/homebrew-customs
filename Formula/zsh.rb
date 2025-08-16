class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.9/zsh-5.9.tar.xz"
  mirror "https://www.zsh.org/pub/zsh-5.9.tar.xz"
  sha256 "9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5"
  license all_of: [
    "MIT-Modern-Variant",
    "GPL-2.0-only", # Completion/Linux/Command/_qdbus, Completion/openSUSE/Command/{_osc,_zypper}
    "GPL-2.0-or-later", # Completion/Unix/Command/_darcs
    "ISC", # Src/openssh_bsd_setres_id.c
  ]
  revision 5

  livecheck do
    url "https://sourceforge.net/projects/zsh/rss?path=/zsh"
  end

  depends_on "ncurses"
  depends_on "pcre2"

  on_macos do
    depends_on "autoconf" => :build
  end

  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.9/zsh-5.9-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.9-doc.tar.xz"
    sha256 "6f7c091249575e68c177c5e8d5c3e9705660d0d3ca1647aea365fd00a0bd3e8a"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/16.0.0/wcwidth9.h"
    sha256 "a9ddb9059f0a17dc0efee89e7ed73c9b0412b10111987090068f49ba708bfa70"
  end

  patch do
    url "https://deb.debian.org/debian/pool/main/z/zsh/zsh_5.9-8.debian.tar.xz"
    sha256 "001e005ed93c3c93fd3474ddbd473c06770ce470188a299a58aeb73106f1bcb2"
    apply %w[
      patches/further-mitigate-test-suite-hangs.patch
      patches/update-debian-sections.patch
      patches/use-pager-instead-of-more-by-default.patch
      patches/cherry-pick-3e3cfabc-revert-38150-and-fix-in-calling-function-cfp_matcher_range-instead.patch
      patches/cherry-pick-4b7a9fd0-additional-typset--p--m-fix-for-namespaces.patch
      patches/cherry-pick-b62e91134-51723-migrate-pcre-module-to-pcre2.patch
      patches/cherry-pick-10bdbd8b-51877-do-not-build-pcre-module-if-pcre2-config-is-not-found.patch
      patches/cherry-pick-ecd3f9c9-1057610-support-texinfo-7.0.patch
      patches/cherry-pick-4c89849c-50641-use-int-main-in-test-C-codes-in-configure.patch
      patches/cherry-pick-ab4d62eb-52383-Avoid-incompatible-pointer-types-in-terminfo-global.patch
      patches/cherry-pick-0bb140f9-52999-import-OLDPWD-from-environment-if-set.patch
      patches/cherry-pick-727b493e-50736-silence-use-after-free-warning.patch
    ]
  end

  def install
    resource("wcwidth9.h").stage(buildpath/"Src")

    Formula["ncurses"].tap do |ncurses|
      ENV.append_to_cflags "-I#{ncurses.include}"
      ENV.append "LDFLAGS", "-L#{ncurses.lib}"
    end

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    # Fix compile with newer Clang
    # https://www.zsh.org/mla/workers/2020/index.html
    # https://github.com/Homebrew/homebrew-core/issues/64921
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1200

    system "Util/preconfig"

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

    system "make", "install"

    resource("htmldoc").stage do
      (pkgshare/"htmldoc").install Dir["Doc/*.html"]
    end
  end

  test do
    assert_equal "homebrew", shell_output("#{bin}/zsh -c 'echo homebrew'").chomp
    system bin/"zsh", "-c", "printf -v hello -- '%s'"
  end
end
