require 'formula'

class Openssh < Formula
  homepage 'http://www.openssh.com/'
  url 'http://ftp5.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.1p1.tar.gz'
  version '6.1p1'
  sha1 '751c92c912310c3aa9cadc113e14458f843fc7b3'

  depends_on 'openssl'

  def install
    system "./configure", "--with-libedit", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
