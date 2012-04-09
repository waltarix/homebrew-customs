require 'formula'

class Ncurses < Formula
  url 'http://ftpmirror.gnu.org/ncurses/ncurses-5.9.tar.gz'
  homepage 'http://www.gnu.org/s/ncurses/'
  sha1 '3e042e5f2c7223bffdaac9646a533b8c758b65b5'

  def options
    [['--universal', 'Build for both 32 & 64 bit Intel.']]
  end

  def install
    ENV.universal_binary if ARGV.build_universal?

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--with-shared",
                          "--with-widec",
                          "--with-manpage-format=normal",
                          "--enable-symlinks",
                          "--enable-widec"
    system "make"
    system "make install"
  end
end