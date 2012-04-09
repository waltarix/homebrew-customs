require 'formula'

class Canything < Formula
  homepage 'https://github.com/keiji0/canything'
  url 'https://github.com/keiji0/canything/tarball/master'
  md5 'b32f80adf2b7b4a73cee9eda57bfeb2a'
  version '20110511'

  def install
    inreplace 'Makefile', '-lncursesw', "-I#{HOMEBREW_PREFIX}/include -L#{HOMEBREW_PREFIX}/lib -lncursesw"
    system 'make'
    bin.install 'canything'
  end
end
