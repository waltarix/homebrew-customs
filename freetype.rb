require 'formula'

class Freetype < Formula
  homepage 'http://www.freetype.org'
  url 'https://downloads.sf.net/project/freetype/freetype2/2.5.3/freetype-2.5.3.tar.bz2'
  sha1 'd3c26cc17ec7fe6c36f4efc02ef92ab6aa3f4b46'
  revision 1

  bottle do
    cellar :any
    revision 1
    sha1 "1c955caa22b5226b6ad18c03fb9a6ffb9c88659b" => :yosemite
    sha1 "f31e54b32a34a69998e120706ba13a99a948c190" => :mavericks
    sha1 "d2f7099c87fe2dc8e969337326f1fe3036d4874e" => :mountain_lion
    sha1 "df246259dde3352bac99dc08af757604c06a2e09" => :lion
  end

  keg_only :provided_pre_mountain_lion

  option :universal

  depends_on "libpng"

  def pour_bottle?
    false
  end

  def patches
    %w[
      https://raw.githubusercontent.com/bohoomil/fontconfig-ultimate/pkgbuild/01_freetype2-iu/freetype-2.5.3-enable-valid.patch
      https://raw.githubusercontent.com/bohoomil/fontconfig-ultimate/pkgbuild/01_freetype2-iu/upstream-2014.11.21.patch
      https://raw.githubusercontent.com/bohoomil/fontconfig-ultimate/pkgbuild/01_freetype2-iu/infinality-2.5.3-2014.11.21.patch
    ]
  end

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}", "--without-harfbuzz"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/freetype-config", '--cflags', '--libs', '--ftversion',
      '--exec-prefix', '--prefix'
  end
end
