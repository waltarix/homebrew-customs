require 'formula'

class Coreutils < Formula
  homepage 'http://www.gnu.org/software/coreutils'
  url 'http://ftpmirror.gnu.org/coreutils/coreutils-8.15.tar.xz'
  mirror 'http://ftp.gnu.org/gnu/coreutils/coreutils-8.15.tar.xz'
  sha256 '837eb377414eae463fee17d0f77e6d76bed79b87bc97ef0c23887710107fd49c'

  depends_on 'xz' => :build

  def patches
    'https://gist.github.com/raw/1408362/fcceeae3987242dc6c0e0288bdbf1dd796ced6d8/coreutils-ls-utf8mac.patch'
  end

  def install
    ENV['LIBS'] = '-liconv'
    system "./configure", "--prefix=#{prefix}", "--program-prefix=g"
    system "make install"

    # create a gnubin dir that has all the commands without program-prefix
    mkdir_p libexec+'gnubin'
    Dir['../../bin/*'].each do |g|
      ln_sf g, libexec+"gnubin/#{File.basename(g)[1..-1]}"
    end
  end

  def caveats; <<-EOS.undent
    All commands have been installed with the prefix 'g'.

    If you really need to use these commands with their normal names, you
    can add a "gnubin" directory to your PATH from your bashrc like:

        PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
    EOS
  end
end
