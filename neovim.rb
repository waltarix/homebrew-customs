class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"

  stable do
    url "https://github.com/neovim/neovim/archive/v0.3.8.tar.gz"
    sha256 "953e134568d824dad7cbf32ee3114951732f9a750c462e430e6b593f418af76c"

    depends_on "jemalloc"
  end

  bottle do
    sha256 "6cfd2fa392a29729a4bf46764efddc5462189d555d5c4910f960af2438ecf4a4" => :mojave
    sha256 "97b6c3dc5dda485bd195650be9e060304e2a03ed2c62bdedf643876971726657" => :high_sierra
    sha256 "3c46065de77aaa929da89748bbf3fe584fe6ef8d9d9919267c7a5bba3f2a345b" => :sierra
  end

  head do
    url "https://github.com/neovim/neovim.git"

    resource "lua-compat-5.3" do
      url "https://github.com/keplerproject/lua-compat-5.3/archive/v0.7.tar.gz"
      sha256 "bec3a23114a3d9b3218038309657f0f506ad10dfbc03bb54e91da7e5ffdba0a2"
    end

    resource "luv" do
      url "https://github.com/luvit/luv/releases/download/1.30.0-0/luv-1.30.0-0.tar.gz"
      sha256 "5cc75a012bfa9a5a1543d0167952676474f31c2d7fd8d450b56d8929dbebb5ef"
    end
  end

  depends_on "cmake" => :build
  depends_on "luarocks" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libtermkey"
  depends_on "libuv"
  depends_on "libvterm"
  depends_on "luajit"
  depends_on "msgpack"
  depends_on "unibilium"

  def pour_bottle?
    false
  end

  resource "mpack" do
    url "https://github.com/libmpack/libmpack-lua/releases/download/1.0.7/libmpack-lua-1.0.7.tar.gz"
    sha256 "68565484a3441d316bd51bed1cacd542b7f84b1ecfd37a8bd18dd0f1a20887e8"
  end

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.2-1.src.rock"
    sha256 "e0d0d687897f06588558168eeb1902ac41a11edd1b58f1aa61b99d0ea0abbfbc"
  end

  resource "inspect" do
    url "https://luarocks.org/manifests/kikito/inspect-3.1.1-0.src.rock"
    sha256 "ea1f347663cebb523e88622b1d6fe38126c79436da4dbf442674208aa14a8f4c"
  end

  patch :DATA

  def install
    resources.each do |r|
      r.stage(buildpath/"deps-build/build/src/#{r.name}")
    end

    ENV.prepend_path "LUA_PATH", "#{buildpath}/deps-build/share/lua/5.1/?.lua"
    ENV.prepend_path "LUA_CPATH", "#{buildpath}/deps-build/lib/lua/5.1/?.so"
    lua_path = "--lua-dir=#{Formula["luajit"].opt_prefix}"

    cd "deps-build" do
      %w[
        mpack/mpack-1.0.7-0.rockspec
        lpeg/lpeg-1.0.2-1.src.rock
        inspect/inspect-3.1.1-0.src.rock
      ].each do |rock|
        dir, rock = rock.split("/")
        cd "build/src/#{dir}" do
          output = Utils.popen_read("luarocks", "unpack", lua_path, rock, "--tree=#{buildpath}/deps-build")
          unpack_dir = output.split("\n")[-2]
          cd unpack_dir do
            system "luarocks", "make", lua_path, "--tree=#{buildpath}/deps-build"
          end
        end
      end

      if build.head?
        cd "build/src/luv" do
          cmake_args = std_cmake_args.reject { |s| s["CMAKE_INSTALL_PREFIX"] }
          cmake_args += %W[
            -DCMAKE_INSTALL_PREFIX=#{buildpath}/deps-build
            -DLUA_BUILD_TYPE=System
            -DWITH_SHARED_LIBUV=ON
            -DBUILD_SHARED_LIBS=OFF
            -DBUILD_MODULE=OFF
            -DLUA_COMPAT53_DIR=#{buildpath}/deps-build/build/src/lua-compat-5.3
          ]
          system "cmake", ".", *cmake_args
          system "make", "install"
        end
      end
    end

    mkdir "build" do
      cmake_args = std_cmake_args
      if build.head?
        cmake_args += %W[
          -DLIBLUV_INCLUDE_DIR=#{buildpath}/deps-build/include
          -DLIBLUV_LIBRARY=#{buildpath}/deps-build/lib/libluv.a
        ]
      end
      system "cmake", "..", *cmake_args
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
