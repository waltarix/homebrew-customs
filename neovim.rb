class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/v0.3.1.tar.gz"
  sha256 "bc5e392d4c076407906ccecbc283e1a44b7832c2f486cad81aa04cc29973ad22"
  head "https://github.com/neovim/neovim.git"
  revision 1

  bottle do
    rebuild 1
    sha256 "315fe4f3aec480fb8d7c4d47b49bf505d35b8b95131190245a743b726d077836" => :high_sierra
    sha256 "9926409ab57d24213668063e4587d3108dba111523e1aa5884370d4cb177721d" => :sierra
    sha256 "3e344efabcf387d60ba6913490f42b53d1cf0e31ef709dec4eb5818e4f6b50d3" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "luarocks" => :build
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

  patch :DATA

  def pour_bottle?
    false
  end

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.1-1.src.rock"
    sha256 "149be31e0155c4694f77ea7264d9b398dd134eca0d00ff03358d91a6cfb2ea9d"
  end

  resource "mpack" do
    url "https://github.com/libmpack/libmpack-lua/releases/download/1.0.7/libmpack-lua-1.0.7.tar.gz"
    sha256 "68565484a3441d316bd51bed1cacd542b7f84b1ecfd37a8bd18dd0f1a20887e8"
  end

  resource "inspect" do
    url "https://luarocks.org/manifests/kikito/inspect-3.1.1-0.src.rock"
    sha256 "ea1f347663cebb523e88622b1d6fe38126c79436da4dbf442674208aa14a8f4c"
  end

  resource "luabitop" do
    url "https://luarocks.org/luabitop-1.0.2-1.src.rock"
    sha256 "fc7a8065a57462ee13bed7f95b0ab13f94ecd1bf846108c61ccf2c75548af26e"
  end

  resource "luafilesystem" do
    url "https://luarocks.org/luafilesystem-1.7.0-2.src.rock"
    sha256 "65e6d437e577a1d6cd509b6cd224d2cb9501d58d32a72cafbd4fd3f911681576"
  end

  resource "penlight" do
    url "https://stevedonovan.github.io/files/penlight-1.5.4.zip"
    sha256 "1855dca3c05b348034df6a8c8784c35a0209e12d21fc4b5c9db84d7383480e8d"
  end

  resource "lua_cliargs" do
    url "https://luarocks.org/lua_cliargs-3.0-1.src.rock"
    sha256 "d165b627b11dc83a11270d7d51760e5b714e3fd2388733c32af53e9b63bf27d4"
  end

  resource "lua-term" do
    url "https://github.com/hoelzro/lua-term/archive/0.07.tar.gz"
    sha256 "c1a1d0c57107147ea02878a50b768d1c3c13aca2769b026c5bb7a84119607f30"
  end

  resource "luasystem" do
    url "https://luarocks.org/luasystem-0.2.1-0.src.rock"
    sha256 "d1c706d48efc7279d33f5ea123acb4d27e2ee93e364bedbe07f2c9c8d0ad3d24"
  end

  resource "dkjson" do
    url "https://luarocks.org/dkjson-2.5-2.src.rock"
    sha256 "0391ebe73cfcee7d6b3d5dd5098e185c2103118e644688484beea665f15fc9e3"
  end

  resource "say" do
    url "https://github.com/Olivine-Labs/say/archive/v1.3-1.tar.gz"
    version "1.3-1"
    sha256 "23e8cd378bb4ab1693279100a785acb2246418e3570b7de7d995b5847b3507ca"
  end

  resource "luassert" do
    url "https://github.com/Olivine-Labs/luassert/archive/v1.7.10.tar.gz"
    sha256 "f9f8347727c2a4aa8af30d88a0de0314f04cd681b60430e24f6ec0ed393e12e1"
  end

  resource "mediator_lua" do
    url "https://github.com/Olivine-Labs/mediator_lua/archive/v1.1.2-0.tar.gz"
    version "1.1.2-0"
    sha256 "faf5859fd2081be4e9e4fb8873a2dc65f7eff3fd93d6dd14da65f8e123fcff9b"
  end

  resource "busted" do
    url "https://github.com/Olivine-Labs/busted/archive/v2.0.rc12-1.tar.gz"
    version "2.0.rc12-1"
    sha256 "c44286468babcc38e90f036d25471ab92f19a8a0a68482e0c45a9cfaeb1c0e35"
  end

  resource "luacheck" do
    url "https://luarocks.org/manifests/mpeterv/luacheck-0.21.2-1.src.rock"
    version "0.21.2-1"
    sha256 "c9e9b3bf1610e382043c6348417864541327108da92290a3be454c40be439953"
  end

  resource "luv" do
    url "https://luarocks.org/luv-1.9.1-1.src.rock"
    sha256 "d72db8321d8b3be925e1c14e6c13081466d1c31420f600154ab5c77fe6974fac"
  end

  resource "coxpcall" do
    url "https://luarocks.org/coxpcall-1.17.0-1.src.rock"
    version "1.17.0-1"
    sha256 "11feb07f08927c39b0b93e8c0bbaf15433f86155cba4820a31a09f4754ab3258"
  end

  resource "nvim-client" do
    url "https://github.com/neovim/lua-client/archive/0.1.0-1.tar.gz"
    version "0.1.0-1"
    sha256 "d2254c70eab7e7b6d7dc07caffe06f1015897fc09fdfa4b33f0b3745e6b0d03c"
  end

  def install
    resources.each do |r|
      r.stage(buildpath/"deps-build/build/src/#{r.name}")
    end

    ENV.prepend_path "LUA_PATH", "#{buildpath}/deps-build/share/lua/5.1/?.lua"
    ENV.prepend_path "LUA_CPATH", "#{buildpath}/deps-build/lib/lua/5.1/?.so"
    lua_path = "--lua-dir=#{Formula["lua@5.1"].opt_prefix}"

    cd "deps-build" do
      %w[
        lpeg/lpeg-1.0.1-1.src.rock
        mpack/mpack-1.0.7-0.rockspec
        inspect/inspect-3.1.1-0.src.rock
        luabitop/luabitop-1.0.2-1.src.rock
        luafilesystem/luafilesystem-1.7.0-2.src.rock
        lua_cliargs/lua_cliargs-3.0-1.src.rock
        lua-term/lua-term-0.7-1.rockspec
        luasystem/luasystem-0.2.1-0.src.rock
        dkjson/dkjson-2.5-2.src.rock
        say/say-1.3-1.rockspec
        luassert/luassert-1.7.10-0.rockspec
        mediator_lua/mediator_lua-1.1.2-0.rockspec
        busted/busted-2.0.rc12-1.rockspec
        luacheck/luacheck-0.21.2-1.src.rock
        luv/luv-1.9.1-1.src.rock
        coxpcall/coxpcall-1.17.0-1.src.rock
        nvim-client/nvim-client-0.1.0-1.rockspec
      ].each do |rock|
        system "luarocks", "build", lua_path, "build/src/#{rock}", "--tree=."
      end

      cd "build/src/penlight" do
        system "luarocks", "make", lua_path, "--tree=#{buildpath}/deps-build"
      end

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
index cb489c340..80ce60c95 100644
--- a/unicode/EastAsianWidth.txt
+++ b/unicode/EastAsianWidth.txt
@@ -1140,12 +1140,12 @@
 2460..249B;A     # No    [60] CIRCLED DIGIT ONE..NUMBER TWENTY FULL STOP
 249C..24E9;A     # So    [78] PARENTHESIZED LATIN SMALL LETTER A..CIRCLED LATIN SMALL LETTER Z
 24EA;N           # No         CIRCLED DIGIT ZERO
-24EB..24FF;A     # No    [21] NEGATIVE CIRCLED NUMBER ELEVEN..NEGATIVE CIRCLED DIGIT ZERO
-2500..254B;A     # So    [76] BOX DRAWINGS LIGHT HORIZONTAL..BOX DRAWINGS HEAVY VERTICAL AND HORIZONTAL
+24EB..24FF;H     # No    [21] NEGATIVE CIRCLED NUMBER ELEVEN..NEGATIVE CIRCLED DIGIT ZERO
+2500..254B;H     # So    [76] BOX DRAWINGS LIGHT HORIZONTAL..BOX DRAWINGS HEAVY VERTICAL AND HORIZONTAL
 254C..254F;N     # So     [4] BOX DRAWINGS LIGHT DOUBLE DASH HORIZONTAL..BOX DRAWINGS HEAVY DOUBLE DASH VERTICAL
 2550..2573;A     # So    [36] BOX DRAWINGS DOUBLE HORIZONTAL..BOX DRAWINGS LIGHT DIAGONAL CROSS
 2574..257F;N     # So    [12] BOX DRAWINGS LIGHT LEFT..BOX DRAWINGS HEAVY UP AND LIGHT DOWN
-2580..258F;A     # So    [16] UPPER HALF BLOCK..LEFT ONE EIGHTH BLOCK
+2580..258F;H     # So    [16] UPPER HALF BLOCK..LEFT ONE EIGHTH BLOCK
 2590..2591;N     # So     [2] RIGHT HALF BLOCK..LIGHT SHADE
 2592..2595;A     # So     [4] MEDIUM SHADE..RIGHT ONE EIGHTH BLOCK
 2596..259F;N     # So    [10] QUADRANT LOWER LEFT..QUADRANT UPPER RIGHT AND LOWER LEFT AND LOWER RIGHT
@@ -1662,7 +1662,9 @@ D7CB..D7FB;N     # Lo    [49] HANGUL JONGSEONG NIEUN-RIEUL..HANGUL JONGSEONG PHI
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
