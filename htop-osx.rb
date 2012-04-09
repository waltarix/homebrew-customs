require 'formula'

class HtopOsx < Formula
  homepage 'https://github.com/AndyA/htop-osx'
  url 'https://github.com/AndyA/htop-osx.git', :branch => 'osx'
  version '0.8.2.1'

  def install
    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make install-exec"
    system "make install-man"
  end
end
