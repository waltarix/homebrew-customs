class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "http://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.1.1/zsh-5.1.1.tar.gz"
  mirror "http://www.zsh.org/pub/zsh-5.1.1.tar.gz"
  sha256 "94ed5b412023761bc8d2f03c173f13d625e06e5d6f0dff2c7a6e140c3fa55087"

  bottle do
    sha256 "ef2e5dd13668edd59725b6a320db7513a6635ec7d3fd30891eb4e87ace6887e8" => :yosemite
    sha256 "313444fc801db870fce3855e3ecda1f8a63aa24e44aaa448805d2dd61e62d584" => :mavericks
    sha256 "78563c521de6861a2278f8e9d44aa8eac86e5c699d0d75018f805ec34286c9cd" => :mountain_lion
  end

  def pour_bottle?
    false
  end

  option "without-etcdir", "Disable the reading of Zsh rc files in /etc"

  deprecated_option "disable-etcdir" => "without-etcdir"

  depends_on "gdbm"
  depends_on "pcre"
  depends_on "homebrew/dupes/ncurses"

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1407905/raw/f7b16c21df602c2b1b866b78939206c00ca8511d/zsh-ambiguous-width-cjk.patch"
    sha256 "a0a903033a2a9c2f7da8d72713ece9721f187036e35568df824132360b8ca5ca"
  end

  def install
    ncurses = Formula["ncurses"]
    ENV.append "LDFLAGS", "-L#{ncurses.lib}"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}"

    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{share}/zsh/functions
      --enable-scriptdir=#{share}/zsh/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-runhelpdir=#{share}/zsh/help
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
      --enable-locale
      --with-term-lib=ncursesw
      zsh_cv_c_broken_wcwidth=yes
    ]

    if build.without? "etcdir"
      args << "--disable-etcdir"
    else
      args << "--enable-etcdir=/etc"
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    system "make", "install"
    system "make", "install.info"
  end

  def caveats; <<-EOS.undent
    Add the following to your zshrc to access the online help:
      unalias run-help
      autoload run-help
      HELPDIR=#{HOMEBREW_PREFIX}/share/zsh/help
    EOS
  end

  test do
    assert_equal "homebrew\n",
      shell_output("#{bin}/zsh -c 'echo homebrew'")
  end
end
