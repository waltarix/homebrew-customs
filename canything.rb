require 'formula'

class Canything < Formula
  homepage 'https://github.com/keiji0/canything'
  url 'https://github.com/keiji0/canything/tarball/88a5ca824e721407458767e06212b79902055f9f'
  sha1 '0f23889be8d74c586c7f190f7174cba8a067e469'
  version '20130128'

  depends_on 'waltarix/customs/ncurses'

  def install
    inreplace 'Makefile', '-lncursesw', "-I#{HOMEBREW_PREFIX}/include -L#{HOMEBREW_PREFIX}/lib -lncursesw"
    system 'make'
    bin.install 'canything'
  end
end
