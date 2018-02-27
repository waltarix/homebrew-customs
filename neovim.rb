class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/v0.2.2.tar.gz"
  sha256 "a838ee07cc9a2ef8ade1b31a2a4f2d5e9339e244ade68e64556c1f4b40ccc5ed"
  revision 3
  head "https://github.com/neovim/neovim.git"

  bottle do
    sha256 "5511bf90172647f7b0eda6587a5b1e43cee22401bed32a40344f9205d32be48e" => :high_sierra
    sha256 "e05a7844a25e252ca9460331cc4522eeda7c213124306324cbbd4fb9e45b10b3" => :sierra
    sha256 "d5d62f862a89868655f9d0ab12a8742e4ec605a96a7c44a7e23cfe2961fb5542" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "lua@5.1" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "jemalloc"
  depends_on "libtermkey"
  depends_on "libuv"
  depends_on "libvterm"
  depends_on "luajit"
  depends_on "msgpack"
  depends_on "unibilium"
  depends_on "python" if MacOS.version <= :snow_leopard

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.1-1.src.rock", :using => :nounzip
    sha256 "149be31e0155c4694f77ea7264d9b398dd134eca0d00ff03358d91a6cfb2ea9d"
  end

  resource "mpack" do
    url "https://luarocks.org/manifests/tarruda/mpack-1.0.6-0.src.rock", :using => :nounzip
    sha256 "9068d9d3f407c72a7ea18bc270b0fa90aad60a2f3099fa23d5902dd71ea4cd5f"
  end

  patch :DATA

  def pour_bottle?
    false
  end

  def install
    resources.each do |r|
      r.stage(buildpath/"deps-build/build/src/#{r.name}")
    end

    ENV.prepend_path "LUA_PATH", "#{buildpath}/deps-build/share/lua/5.1/?.lua"
    ENV.prepend_path "LUA_CPATH", "#{buildpath}/deps-build/lib/lua/5.1/?.so"

    cd "deps-build" do
      system "luarocks-5.1", "build", "build/src/lpeg/lpeg-1.0.1-1.src.rock", "--tree=."
      system "luarocks-5.1", "build", "build/src/mpack/mpack-1.0.6-0.src.rock", "--tree=."
      system "cmake", "../third-party", "-DUSE_BUNDLED=OFF", *std_cmake_args
      system "make"
    end

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.txt").write("Hello World from Vim!!")
    system bin/"nvim", "--headless", "-i", "NONE", "-u", "NONE",
                       "+s/Vim/Neovim/g", "+wq", "test.txt"
    assert_equal "Hello World from Neovim!!", (testpath/"test.txt").read.chomp
  end
end

__END__
diff --git a/unicode/EastAsianWidth.txt b/unicode/EastAsianWidth.txt
index 0d3129bb0..a227e0c0f 100644
--- a/unicode/EastAsianWidth.txt
+++ b/unicode/EastAsianWidth.txt
@@ -1132,12 +1132,12 @@
 2460..249B;A     # No    [60] CIRCLED DIGIT ONE..NUMBER TWENTY FULL STOP
 249C..24E9;A     # So    [78] PARENTHESIZED LATIN SMALL LETTER A..CIRCLED LATIN SMALL LETTER Z
 24EA;N           # No         CIRCLED DIGIT ZERO
-24EB..24FF;A     # No    [21] NEGATIVE CIRCLED NUMBER ELEVEN..NEGATIVE CIRCLED DIGIT ZERO
+24EB..24FF;H     # No    [21] NEGATIVE CIRCLED NUMBER ELEVEN..NEGATIVE CIRCLED DIGIT ZERO
 2500..254B;A     # So    [76] BOX DRAWINGS LIGHT HORIZONTAL..BOX DRAWINGS HEAVY VERTICAL AND HORIZONTAL
 254C..254F;N     # So     [4] BOX DRAWINGS LIGHT DOUBLE DASH HORIZONTAL..BOX DRAWINGS HEAVY DOUBLE DASH VERTICAL
 2550..2573;A     # So    [36] BOX DRAWINGS DOUBLE HORIZONTAL..BOX DRAWINGS LIGHT DIAGONAL CROSS
 2574..257F;N     # So    [12] BOX DRAWINGS LIGHT LEFT..BOX DRAWINGS HEAVY UP AND LIGHT DOWN
-2580..258F;A     # So    [16] UPPER HALF BLOCK..LEFT ONE EIGHTH BLOCK
+2580..258F;H     # So    [16] UPPER HALF BLOCK..LEFT ONE EIGHTH BLOCK
 2590..2591;N     # So     [2] RIGHT HALF BLOCK..LIGHT SHADE
 2592..2595;A     # So     [4] MEDIUM SHADE..RIGHT ONE EIGHTH BLOCK
 2596..259F;N     # So    [10] QUADRANT LOWER LEFT..QUADRANT UPPER RIGHT AND LOWER LEFT AND LOWER RIGHT
@@ -1656,7 +1656,9 @@ D7CB..D7FB;N     # Lo    [49] HANGUL JONGSEONG NIEUN-RIEUL..HANGUL JONGSEONG PHI
 D800..DB7F;N     # Cs   [896] <surrogate-D800>..<surrogate-DB7F>
 DB80..DBFF;N     # Cs   [128] <surrogate-DB80>..<surrogate-DBFF>
 DC00..DFFF;N     # Cs  [1024] <surrogate-DC00>..<surrogate-DFFF>
-E000..F8FF;A     # Co  [6400] <private-use-E000>..<private-use-F8FF>
+E000..E09F;A     # Co   [160] <private-use-E000>..<private-use-E09F>
+E0A0..E0D7;H     # Co    [56] <powerline-symbols-E0A0>..<powerline-symbols-E0D7>
+E0D8..F8FF;A     # Co  [6184] <private-use-E0D8>..<private-use-F8FF>
 F900..FA6D;W     # Lo   [366] CJK COMPATIBILITY IDEOGRAPH-F900..CJK COMPATIBILITY IDEOGRAPH-FA6D
 FA6E..FA6F;W     # Cn     [2] <reserved-FA6E>..<reserved-FA6F>
 FA70..FAD9;W     # Lo   [106] CJK COMPATIBILITY IDEOGRAPH-FA70..CJK COMPATIBILITY IDEOGRAPH-FAD9
