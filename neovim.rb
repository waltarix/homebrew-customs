class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/v0.7.0.tar.gz"
  sha256 "792a9c55d5d5f4a5148d475847267df309d65fb20f05523f21c1319ea8a6c7df"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  if OS.linux?
    depends_on "waltarix/customs/libtree-sitter"
    depends_on "libnsl"
  else
    depends_on "tree-sitter"
  end

  depends_on "cmake" => :build
  # Libtool is needed to build `libvterm`.
  # Remove this dependency when we use the formula.
  depends_on "libtool" => :build
  depends_on "luarocks" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libtermkey"
  depends_on "libuv"
  depends_on "luajit-openresty"
  depends_on "luv"
  depends_on "msgpack"
  depends_on "unibilium"
  depends_on "waltarix/customs/jemalloc"

  uses_from_macos "gperf" => :build
  uses_from_macos "unzip" => :build

  # TODO: Use `libvterm` formula when the following is resolved:
  # https://github.com/neovim/neovim/pull/16219
  resource "libvterm" do
    url "http://www.leonerd.org.uk/code/libvterm/libvterm-0.1.4.tar.gz"
    sha256 "bc70349e95559c667672fc8c55b9527d9db9ada0fb80a3beda533418d782d3dd"
    patch <<~PATCH
      diff --git a/src/unicode.c b/src/unicode.c
      index 0d1b5ff..28ea8c5 100644
      --- a/src/unicode.c
      +++ b/src/unicode.c
      @@ -1,4 +1,5 @@
       #include "vterm_internal.h"
      +#include "wcwidth9.h"
       
       // ### The following from http://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
       // With modifications:
      @@ -325,10 +326,7 @@ static const struct interval fullwidth[] = {
       
       INTERNAL int vterm_unicode_width(uint32_t codepoint)
       {
      -  if(bisearch(codepoint, fullwidth, sizeof(fullwidth) / sizeof(fullwidth[0]) - 1))
      -    return 2;
      -
      -  return mk_wcwidth(codepoint);
      +  return wcwidth9(codepoint);
       }
       
       INTERNAL int vterm_unicode_is_combining(uint32_t codepoint)
    PATCH
  end

  # Keep resources updated according to:
  # https://github.com/neovim/neovim/blob/v#{version}/third-party/CMakeLists.txt

  resource "mpack" do
    url "https://github.com/libmpack/libmpack-lua/releases/download/1.0.9/libmpack-lua-1.0.9.tar.gz"
    sha256 "0fd07e709c3f6f201c2ffc9f77cef1b303b02c12413f0c15670a32bf6c959e9e"
  end

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.2-1.src.rock"
    sha256 "e0d0d687897f06588558168eeb1902ac41a11edd1b58f1aa61b99d0ea0abbfbc"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/14.0.0-r2/wcwidth9.h"
    sha256 "8ce9e402611a0f8c2a44130571d9043144d43463893e13a6459d0b2c22b67eb2"
  end

  patch :DATA

  def install
    res = resources.reject { |r| r.name == "wcwidth9.h" }
    res.each { |r| r.stage(buildpath/"deps-build/build/src"/r.name) }
    resource("wcwidth9.h").tap do |r|
      r.stage(buildpath/"src/nvim")
      r.stage(buildpath/"deps-build/build/src/libvterm/src")
    end

    system "sh", buildpath/"scripts/download-unicode-files.sh"

    # The path separator for `LUA_PATH` and `LUA_CPATH` is `;`.
    ENV.prepend "LUA_PATH", buildpath/"deps-build/share/lua/5.1/?.lua", ";"
    ENV.prepend "LUA_CPATH", buildpath/"deps-build/lib/lua/5.1/?.so", ";"
    # Don't clobber the default search path
    ENV.append "LUA_PATH", ";", ";"
    ENV.append "LUA_CPATH", ";", ";"
    lua_path = "--lua-dir=#{Formula["luajit-openresty"].opt_prefix}"

    cd "deps-build/build/src" do
      %w[
        mpack/mpack-1.0.9-0.rockspec
        lpeg/lpeg-1.0.2-1.src.rock
      ].each do |rock|
        dir, rock = rock.split("/")
        cd dir do
          output = Utils.safe_popen_read("luarocks", "unpack", lua_path, rock, "--tree=#{buildpath}/deps-build")
          unpack_dir = output.split("\n")[-2]
          cd unpack_dir do
            on_macos do
              inreplace "lmpack.c", "#define _XOPEN_SOURCE 500", "#define _C99_SOURCE 1" if dir == "mpack"
            end

            system "luarocks", "make", lua_path, "--tree=#{buildpath}/deps-build"
          end
        end
      end

      # Build libvterm. Remove when we use the formula.
      cd "libvterm" do
        system "make", "install", "PREFIX=#{buildpath}/deps-build", "LDFLAGS=-static #{ENV.ldflags}"
        ENV.prepend_path "PKG_CONFIG_PATH", buildpath/"deps-build/lib/pkgconfig"
      end
    end

    system "cmake", "-S", ".", "-B", "build",
                    "-DLIBLUV_LIBRARY=#{Formula["luv"].opt_lib/shared_library("libluv")}",
                    *std_cmake_args

    # Patch out references to Homebrew shims
    inreplace "build/config/auto/versiondef.h", Superenv.shims_path/ENV.cc, ENV.cc

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    mkdir_p libexec/"bin"
    mv bin/"nvim", libexec/"bin/nvim"
    env = {}.tap do |e|
      libjemalloc = Formula["jemalloc"].opt_lib/shared_library("libjemalloc")
      on_macos { e[:DYLD_INSERT_LIBRARIES] = libjemalloc }
      on_linux { e[:LD_PRELOAD] = libjemalloc }
    end
    (bin/"nvim").write_env_script libexec/"bin/nvim", env
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
index 12474d3c1..a8aa2233c 100755
--- a/scripts/download-unicode-files.sh
+++ b/scripts/download-unicode-files.sh
@@ -1,11 +1,12 @@
 #!/bin/sh
 
 set -e
-data_files="UnicodeData.txt CaseFolding.txt EastAsianWidth.txt"
+data_files="UnicodeData.txt CaseFolding.txt"
 emoji_files="emoji-data.txt"
 
 UNIDIR_DEFAULT=unicode
-DOWNLOAD_URL_BASE_DEFAULT='http://unicode.org/Public'
+UNICODE_VERSION="14.0.0"
+DOWNLOAD_URL_BASE_DEFAULT="https://unicode.org/Public/${UNICODE_VERSION}/ucd"
 
 if test x$1 = 'x--help' ; then
   echo 'Usage:'
@@ -22,22 +23,12 @@ UNIDIR=${1:-$UNIDIR_DEFAULT}
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
 
-(
-  cd "$UNIDIR"
-  git commit -m "Update unicode files" -- $files
-)
+curl -# -L -o "$UNIDIR/EastAsianWidth.txt" \
+  "https://github.com/waltarix/localedata/releases/download/14.0.0-r2/EastAsianWidth.txt"
diff --git a/src/nvim/generators/gen_unicode_tables.lua b/src/nvim/generators/gen_unicode_tables.lua
index aa96c97bc..64cafa984 100644
--- a/src/nvim/generators/gen_unicode_tables.lua
+++ b/src/nvim/generators/gen_unicode_tables.lua
@@ -317,8 +317,7 @@ eaw_fp:close()
 
 local doublewidth = build_width_table(ut_fp, dataprops, widthprops,
                                       {W=true, F=true}, 'doublewidth')
-local ambiwidth = build_width_table(ut_fp, dataprops, widthprops,
-                                    {A=true}, 'ambiguous')
+local ambiwidth = {}
 
 local emoji_fp = io.open(emoji_fname, 'r')
 local emojiprops = parse_emoji_props(emoji_fp)
diff --git a/src/nvim/mbyte.c b/src/nvim/mbyte.c
index f634c7dda..75871d59e 100644
--- a/src/nvim/mbyte.c
+++ b/src/nvim/mbyte.c
@@ -74,6 +74,8 @@ struct interval {
 # include "unicode_tables.generated.h"
 #endif
 
+#include "wcwidth9.h"
+
 // To speed up BYTELEN(); keep a lookup table to quickly get the length in
 // bytes of a UTF-8 character from the first byte of a UTF-8 string.  Bytes
 // which are illegal when used as the first byte have a 1.  The NUL byte has
@@ -471,12 +473,11 @@ static bool intable(const struct interval *table, size_t n_items, int c)
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
@@ -484,27 +485,11 @@ int utf_char2cells(int c)
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
 
@@ -1056,12 +1041,6 @@ bool utf_iscomposing(int c)
  */
 bool utf_printable(int c)
 {
-#ifdef USE_WCHAR_FUNCTIONS
-  /*
-   * Assume the iswprint() library function works better than our own stuff.
-   */
-  return iswprint(c);
-#else
   // Sorted list of non-overlapping intervals.
   // 0xd800-0xdfff is reserved for UTF-16, actually illegal.
   static struct interval nonprint[] =
@@ -1072,7 +1051,6 @@ bool utf_printable(int c)
   };
 
   return !intable(nonprint, ARRAY_SIZE(nonprint), c);
-#endif
 }
 
 /*
@@ -1204,8 +1182,7 @@ int utf_class_tab(const int c, const uint64_t *const chartab)
 
 bool utf_ambiguous_width(int c)
 {
-  return c >= 0x80 && (intable(ambiguous, ARRAY_SIZE(ambiguous), c)
-                       || intable(emoji_all, ARRAY_SIZE(emoji_all), c));
+  return c >= 0x80 && (intable(emoji_all, ARRAY_SIZE(emoji_all), c));
 }
 
 /*
