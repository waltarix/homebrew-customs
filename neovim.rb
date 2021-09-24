class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/v0.5.0.tar.gz"
  sha256 "2294caa9d2011996499fbd70e4006e4ef55db75b99b6719154c09262e23764ef"
  license "Apache-2.0"

  bottle :unneeded

  if OS.linux?
    depends_on "waltarix/customs/libtree-sitter"
    depends_on "libnsl"
  else
    depends_on "tree-sitter"
  end
  depends_on "cmake" => :build
  depends_on "luarocks" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libtermkey"
  depends_on "libuv"
  depends_on "libvterm"
  depends_on "luajit-openresty"
  depends_on "luv"
  depends_on "msgpack"
  depends_on "unibilium"

  uses_from_macos "gperf" => :build
  uses_from_macos "unzip" => :build

  # Keep resources updated according to:
  # https://github.com/neovim/neovim/blob/v#{version}/third-party/CMakeLists.txt

  resource "mpack" do
    url "https://github.com/libmpack/libmpack-lua/releases/download/1.0.8/libmpack-lua-1.0.8.tar.gz"
    sha256 "ed6b1b4bbdb56f26241397c1e168a6b1672f284989303b150f7ea8d39d1bc9e9"
  end

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.2-1.src.rock"
    sha256 "e0d0d687897f06588558168eeb1902ac41a11edd1b58f1aa61b99d0ea0abbfbc"
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
    lua_path = "--lua-dir=#{Formula["luajit-openresty"].opt_prefix}"

    cd "deps-build" do
      %w[
        mpack/mpack-1.0.8-0.rockspec
        lpeg/lpeg-1.0.2-1.src.rock
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
    end

    mkdir "build" do
      system "cmake", "..", *std_cmake_args, "-DLIBLUV_LIBRARY=#{Formula["luv"].opt_lib/shared_library("libluv")}"
      # Patch out references to Homebrew shims
      inreplace "config/auto/versiondef.h", Superenv.shims_path/ENV.cc, ENV.cc
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
index 12474d3c1..0a4164ff0 100755
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
-  curl -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/UNIDATA/emoji/$filename"
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
index ec4f4cbc2..4def85fea 100644
--- a/src/nvim/mbyte.c
+++ b/src/nvim/mbyte.c
@@ -73,6 +73,8 @@ struct interval {
 # include "unicode_tables.generated.h"
 #endif
 
+#include "wcwidth9.h"
+
 char_u e_loadlib[] = "E370: Could not load library %s";
 char_u e_loadfunc[] = "E448: Could not load library function %s";
 
@@ -469,12 +471,11 @@ static bool intable(const struct interval *table, size_t n_items, int c)
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
@@ -482,27 +483,11 @@ int utf_char2cells(int c)
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
 
@@ -1035,12 +1020,6 @@ bool utf_iscomposing(int c)
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
@@ -1051,7 +1030,6 @@ bool utf_printable(int c)
   };
 
   return !intable(nonprint, ARRAY_SIZE(nonprint), c);
-#endif
 }
 
 /*
