require 'formula'

class Pxz < Formula
  homepage 'http://jnovy.fedorapeople.org/pxz/'
  url 'http://jnovy.fedorapeople.org/pxz/pxz-4.999.9beta.20091201git.tar.xz'
  md5 '4ae3926185978f5c95c9414dc4634451'

  head 'https://github.com/jnovy/pxz.git'

  def install
    system "make", "CC=#{ENV.cc}"
                   "CFLAGS=#{ENV.cflags}"
    bin.install "pxz"
    man1.install "pxz.1" if File.exists? "pxz.1"
  end
end
