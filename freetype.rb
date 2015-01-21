class Freetype < Formula
  homepage "http://www.freetype.org"
  url "https://downloads.sf.net/project/freetype/freetype2/2.5.5/freetype-2.5.5.tar.bz2"
  mirror "http://download.savannah.gnu.org/releases/freetype/freetype-2.5.5.tar.bz2"
  sha1 "7b7460ef51a8fdb17baae53c6658fc1ad000a1c2"

  bottle do
    cellar :any
    sha1 "f3c9868e2f0cad854d1f24c5dcc98e304ce9c59e" => :yosemite
    sha1 "c2cab6b497af1b07ce940139bb7dec65c8a2117c" => :mavericks
    sha1 "341bb165aa5c67cecace843be154ef71723d6268" => :mountain_lion
  end

  keg_only :provided_pre_mountain_lion

  option :universal

  depends_on "libpng"

  def pour_bottle?
    false
  end

  patch :p1 do
    url "https://raw.githubusercontent.com/bohoomil/fontconfig-ultimate/48c69b93448ffe2e4b37d837afd1d51599d45fef/freetype/01-freetype-2.5.5-enable-valid.patch"
    sha256 "086c9874ba5217dab419ac03dbc5ad6480aaa67b3c9d802f7181d8a3e007f8eb"
  end

  patch :p1 do
    url "https://raw.githubusercontent.com/bohoomil/fontconfig-ultimate/48c69b93448ffe2e4b37d837afd1d51599d45fef/freetype/02-ftsmooth-2.5.5.patch"
    sha256 "149ed6ec6fbcdffe01077432295fbbfd179a9c23312562e822a3bdd1fbf6aec8"
  end

  patch :p1 do
    url "https://raw.githubusercontent.com/bohoomil/fontconfig-ultimate/48c69b93448ffe2e4b37d837afd1d51599d45fef/freetype/04-infinality-2.5.5-2014.12.30.patch"
    sha256 "532e563aac235b80f01601d157b1d016a4a18fd302bb024dd6d9566e6fc47746"
  end

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}", "--without-harfbuzz"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/freetype-config", "--cflags", "--libs", "--ftversion",
      "--exec-prefix", "--prefix"
  end
end
