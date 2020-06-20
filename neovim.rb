class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/v0.4.3.tar.gz"
  sha256 "91a0b5d32204a821bf414690e6b48cf69224d1961d37158c2b383f6a6cf854d2"
  revision 3

  head do
    url "https://github.com/neovim/neovim.git"
    depends_on "utf8proc"
  end

  bottle :unneeded

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

  resource "lua-compat-5.3" do
    url "https://github.com/keplerproject/lua-compat-5.3/archive/v0.7.tar.gz"
    sha256 "bec3a23114a3d9b3218038309657f0f506ad10dfbc03bb54e91da7e5ffdba0a2"
  end

  resource "luv" do
    url "https://github.com/luvit/luv/releases/download/1.30.0-0/luv-1.30.0-0.tar.gz"
    sha256 "5cc75a012bfa9a5a1543d0167952676474f31c2d7fd8d450b56d8929dbebb5ef"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/13.0.0-r1/wcwidth9.h"
    sha256 "f00b5d73a1bb266c13bae2f9d758eaec59080ad8579cebe7d649ae125b28f9f1"
  end

  patch :DATA

  def install
    resources.each do |r|
      r.stage(buildpath/"deps-build/build/src/#{r.name}")
    end
    resource("wcwidth9.h").stage(buildpath/"src/nvim")

    system "sh", buildpath/"scripts/download-unicode-files.sh"

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
          output = Utils.safe_popen_read("luarocks", "unpack", lua_path, rock, "--tree=#{buildpath}/deps-build")
          unpack_dir = output.split("\n")[-2]
          cd unpack_dir do
            system "luarocks", "make", lua_path, "--tree=#{buildpath}/deps-build"
          end
        end
      end

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

    mkdir "build" do
      cmake_args = std_cmake_args
      cmake_args += %W[
        -DLIBLUV_INCLUDE_DIR=#{buildpath}/deps-build/include
        -DLIBLUV_LIBRARY=#{buildpath}/deps-build/lib/libluv.a
      ]
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
diff --git a/scripts/download-unicode-files.sh b/scripts/download-unicode-files.sh
index 5f38d0589..0a4164ff0 100755
--- a/scripts/download-unicode-files.sh
+++ b/scripts/download-unicode-files.sh
@@ -5,7 +5,8 @@ data_files="UnicodeData.txt CaseFolding.txt EastAsianWidth.txt"
 emoji_files="emoji-data.txt"
 
 UNIDIR_DEFAULT=unicode
-DOWNLOAD_URL_BASE_DEFAULT='http://unicode.org/Public'
+UNICODE_VERSION="13.0.0"
+DOWNLOAD_URL_BASE_DEFAULT="http://unicode.org/Public/${UNICODE_VERSION}/ucd"
 
 if test x$1 = 'x--help' ; then
   echo 'Usage:'
@@ -22,22 +23,9 @@ UNIDIR=${1:-$UNIDIR_DEFAULT}
 DOWNLOAD_URL_BASE=${2:-$DOWNLOAD_URL_BASE_DEFAULT}
 
 for filename in $data_files ; do
-  curl -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/UNIDATA/$filename"
-  (
-    cd "$UNIDIR"
-    git add $filename
-  )
+  curl -# -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/$filename"
 done
 
 for filename in $emoji_files ; do
-  curl -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/emoji/latest/$filename"
-  (
-    cd "$UNIDIR"
-    git add $filename
-  )
+  curl -# -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/emoji/$filename"
 done
-
-(
-  cd "$UNIDIR"
-  git commit -m "Update unicode files" -- $files
-)
diff --git a/src/nvim/mbyte.c b/src/nvim/mbyte.c
index 85e6697bf..b536cb448 100644
--- a/src/nvim/mbyte.c
+++ b/src/nvim/mbyte.c
@@ -73,6 +73,8 @@ struct interval {
 # include "unicode_tables.generated.h"
 #endif
 
+#include "wcwidth9.h"
+
 char_u e_loadlib[] = "E370: Could not load library %s";
 char_u e_loadfunc[] = "E448: Could not load library function %s";
 
@@ -467,12 +469,11 @@ static bool intable(const struct interval *table, size_t n_items, int c)
 int utf_char2cells(int c)
 {
   if (c >= 0x100) {
-#ifdef USE_WCHAR_FUNCTIONS
     //
     // Assume the library function wcwidth() works better than our own
     // stuff.  It should return 1 for ambiguous width chars!
     //
-    int n = wcwidth(c);
+    int n = wcwidth9(c);
 
     if (n < 0) {
       return 6;                 // unprintable, displays <xxxx>
@@ -480,27 +481,11 @@ int utf_char2cells(int c)
     if (n > 1) {
       return n;
     }
-#else
-    if (!utf_printable(c)) {
-      return 6;                 // unprintable, displays <xxxx>
-    }
-    if (intable(doublewidth, ARRAY_SIZE(doublewidth), c)) {
-      return 2;
-    }
-#endif
-    if (p_emoji && intable(emoji_width, ARRAY_SIZE(emoji_width), c)) {
-      return 2;
-    }
   } else if (c >= 0x80 && !vim_isprintc(c)) {
     // Characters below 0x100 are influenced by 'isprint' option.
     return 4;                   // unprintable, displays <xx>
   }
 
-  if (c >= 0x80 && *p_ambw == 'd'
-      && intable(ambiguous, ARRAY_SIZE(ambiguous), c)) {
-    return 2;
-  }
-
   return 1;
 }
 
@@ -1033,12 +1018,6 @@ bool utf_iscomposing(int c)
  */
 bool utf_printable(int c)
 {
-#ifdef USE_WCHAR_FUNCTIONS
-  /*
-   * Assume the iswprint() library function works better than our own stuff.
-   */
-  return iswprint(c);
-#else
   /* Sorted list of non-overlapping intervals.
    * 0xd800-0xdfff is reserved for UTF-16, actually illegal. */
   static struct interval nonprint[] =
@@ -1049,7 +1028,6 @@ bool utf_printable(int c)
   };
 
   return !intable(nonprint, ARRAY_SIZE(nonprint), c);
-#endif
 }
 
 /*
