require 'formula'

class Serf < Formula
  homepage 'http://code.google.com/p/serf/'
  url 'http://serf.googlecode.com/files/serf-1.0.3.tar.bz2'
  sha1 '117fb820fd3541e899ad9a1b3f1b273266493a68'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
