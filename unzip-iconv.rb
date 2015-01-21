require 'formula'

class UnzipIconv < Formula
  homepage 'http://www.info-zip.org/pub/infozip/UnZip.html'
  url 'https://downloads.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz'
  version '6.0'
  sha1 'abf7de8a4018a983590ed6f5cbd990d4740f8a22'

  patch do
    url "https://aur.archlinux.org/packages/un/unzip-iconv/unzip-iconv.tar.gz"
    sha256 "80773aa4047f15757ec92bf7845cf36d33de60a9b480f9797cb623287f6a6c26"

    def unpack
      dir = Pathname.pwd
      super do
        patchfile = Pathname.pwd.children.find { |f| f.fnmatch "*.patch" }
        dir.cd { safe_system "/usr/bin/patch", "-g", "0", "-f", "-p1", "-i", patchfile }
      end
    end
  end

  def install
    system "make", "LFLAGS1=-liconv", "-f", "unix/Makefile", "macosx"
    system "make", "prefix=#{prefix}", "MANDIR=#{man1}", "install"

    [bin, man1].each do |path|
      path.children.each do |f|
        f.rename path/"i#{f.basename.to_s}"
      end
    end
  end

  test do
    system "#{bin}/iunzip", "--help"
  end

  def caveats; <<-EOS.undent
    All commands have been installed with the prefix 'i'.
    EOS
  end
end
