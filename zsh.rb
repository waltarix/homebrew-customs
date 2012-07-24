require 'formula'

class Zsh < Formula
  homepage 'http://www.zsh.org/'
  url 'http://www.zsh.org/pub/zsh-5.0.0.tar.bz2'
  sha1 '692669243433c55384a54b397a1cc926e582e9f2'

  depends_on 'gdbm'
  depends_on 'pcre'
  depends_on 'waltarix/customs/ncurses'

  skip_clean :all

  def patches
    [
      'https://raw.github.com/gist/1407905',
      'https://raw.github.com/gist/1403346'
    ]
  end

  def options
    [['--disable-etcdir', 'Disable the reading of Zsh rc files in /etc']]
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{share}/zsh/functions
      --enable-scriptdir=#{share}/zsh/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
      --enable-locale
      --with-term-lib=ncursesw
    ]

    args << '--disable-etcdir' if ARGV.include? '--disable-etcdir'

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    system "make install"
  end

  def test
    system "#{bin}/zsh", "--version"
  end

  def caveats; <<-EOS.undent
    To use this build of Zsh as your login shell, add it to /etc/shells.

    If you have administrator privileges, you must fix an Apple miss
    configuration in Mac OS X 10.7 Lion by renaming /etc/zshenv to
    /etc/zprofile, or Zsh will have the wrong PATH when executed
    non-interactively by scripts.

    Alternatively, install Zsh with /etc disabled:

      brew install --disable-etcdir zsh
    EOS
  end
end
