require 'formula'

class Zsh < Formula
  homepage 'http://www.zsh.org/'
  url 'https://downloads.sourceforge.net/project/zsh/zsh/5.0.7/zsh-5.0.7.tar.bz2'
  mirror 'http://www.zsh.org/pub/zsh-5.0.7.tar.bz2'
  sha1 '1500191d16af8a71aec4f719a92775a074682096'

  bottle do
    sha1 "83d646649569ade648db6a44c480709d63268a25" => :yosemite
    sha1 "935990ced3a6d3a3027bac4b32ac8f031e8fa244" => :mavericks
    sha1 "c6e8055106d0b939cec5674469099bfd63d53f9e" => :mountain_lion
  end

  def pour_bottle?
    false
  end

  depends_on 'gdbm'
  depends_on 'pcre'
  depends_on 'homebrew/dupes/ncurses'

  option 'disable-etcdir', 'Disable the reading of Zsh rc files in /etc'

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1407905/raw/1987483974248f05c9286bc58d9bc3275610cc16/zsh-ambiguous-width-cjk.patch"
    sha256 "7e0c7d2cc8814716ee74f4d3ec422d91f7b7cae40e9da52ea9aa1b98a8a92464"
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
    ]

    if build.include? 'disable-etcdir'
      args << '--disable-etcdir'
    else
      args << '--enable-etcdir=/etc'
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    system "make", "install"
    system "make", "install.info"
  end

  test do
    system "#{bin}/zsh", "--version"
  end

  def caveats; <<-EOS.undent
    Add the following to your zshrc to access the online help:
      unalias run-help
      autoload run-help
      HELPDIR=#{HOMEBREW_PREFIX}/share/zsh/help
    EOS
  end
end
