class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/982fef6018fb64c883ddafc897c8f7c58fb1c62d.tar.gz"
  sha256 "265cf0a4f9c86e70e34a42c8e83457f11b9cc6bc2b6d82f9ba806e23a17509e8"
  version "0.8.0-dev-1093-g982fef601"
  license "Apache-2.0"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "luarocks" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libtermkey"
  depends_on "libuv"
  depends_on "msgpack"
  depends_on "unibilium"
  depends_on "waltarix/customs/libtree-sitter"
  depends_on "waltarix/customs/libvterm"
  depends_on "waltarix/customs/luajit"
  depends_on "waltarix/customs/luv"

  uses_from_macos "gperf" => :build
  uses_from_macos "unzip" => :build

  on_linux do
    depends_on "libnsl"
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
    url "https://github.com/waltarix/localedata/releases/download/14.0.0-r3/wcwidth9.h"
    sha256 "5797b11ba5712a6a98ad21ed2a2cec71467e2ccd4b0c7fd43ebb16a00ff85bda"
  end

  patch :DATA

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"

    resources.each do |r|
      if r.name == "wcwidth9.h"
        r.stage(buildpath/"src/nvim")
      else
        r.stage(buildpath/"deps-build/build/src"/r.name)
      end
    end

    system "sh", buildpath/"scripts/download-unicode-files.sh"

    # The path separator for `LUA_PATH` and `LUA_CPATH` is `;`.
    ENV.prepend "LUA_PATH", buildpath/"deps-build/share/lua/5.1/?.lua", ";"
    ENV.prepend "LUA_CPATH", buildpath/"deps-build/lib/lua/5.1/?.so", ";"
    # Don't clobber the default search path
    ENV.append "LUA_PATH", ";", ";"
    ENV.append "LUA_CPATH", ";", ";"
    lua_path = "--lua-dir=#{Formula["waltarix/customs/luajit"].opt_prefix}"

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
    end

    # Point system locations inside `HOMEBREW_PREFIX`.
    inreplace "src/nvim/os/stdpaths.c" do |s|
      s.gsub! "/etc/xdg/", "#{etc}/xdg/:\\0"

      unless HOMEBREW_PREFIX.to_s == HOMEBREW_DEFAULT_PREFIX
        s.gsub! "/usr/local/share/:/usr/share/", "#{HOMEBREW_PREFIX}/share/:\\0"
      end
    end

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja",
                    "-DLIBLUV_LIBRARY=#{Formula["luv"].opt_lib/shared_library("libluv")}",
                    "-DLIBUV_LIBRARY=#{Formula["libuv"].opt_lib/shared_library("libuv")}",
                    "-DNVIM_VERSION_MEDIUM=v#{version}",
                    *std_cmake_args

    # Patch out references to Homebrew shims
    inreplace "build/cmake.config/auto/versiondef.h", Superenv.shims_path/ENV.cc, ENV.cc

    ENV.deparallelize
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
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
index 4482cefa3..8e40714b4 100755
--- a/scripts/download-unicode-files.sh
+++ b/scripts/download-unicode-files.sh
@@ -1,11 +1,12 @@
 #!/bin/sh
 
 set -e
-data_files="UnicodeData.txt CaseFolding.txt EastAsianWidth.txt"
+data_files="UnicodeData.txt CaseFolding.txt"
 emoji_files="emoji-data.txt"
 
 UNIDIR_DEFAULT=src/unicode
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
-  git commit -m "feat: update unicode tables" -- $files
-)
+curl -# -L -o "$UNIDIR/EastAsianWidth.txt" \
+  "https://github.com/waltarix/localedata/releases/download/14.0.0-r3/EastAsianWidth.txt"
diff --git a/src/nvim/generators/gen_unicode_tables.lua b/src/nvim/generators/gen_unicode_tables.lua
index 36553f464..6c5cef62a 100644
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
index 83b060905..50b8063b6 100644
--- a/src/nvim/mbyte.c
+++ b/src/nvim/mbyte.c
@@ -74,6 +74,8 @@ struct interval {
 # include "unicode_tables.generated.h"
 #endif
 
+#include "wcwidth9.h"
+
 static char e_list_item_nr_is_not_list[]
   = N_("E1109: List item %d is not a List");
 static char e_list_item_nr_does_not_contain_3_numbers[]
@@ -469,30 +471,16 @@ static bool intable(const struct interval *table, size_t n_items, int c)
 int utf_char2cells(int c)
 {
   if (c >= 0x100) {
-    int n = cw_value(c);
-    if (n != 0) {
-      return n;
-    }
-
-    if (!utf_printable(c)) {
+    int n = wcwidth9(c);
+    if (n < 0) {
       return 6;                 // unprintable, displays <xxxx>
     }
-    if (intable(doublewidth, ARRAY_SIZE(doublewidth), c)) {
-      return 2;
-    }
-    if (p_emoji && intable(emoji_wide, ARRAY_SIZE(emoji_wide), c)) {
-      return 2;
-    }
+    return n;
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
 
@@ -1162,8 +1150,7 @@ int utf_class_tab(const int c, const uint64_t *const chartab)
 
 bool utf_ambiguous_width(int c)
 {
-  return c >= 0x80 && (intable(ambiguous, ARRAY_SIZE(ambiguous), c)
-                       || intable(emoji_all, ARRAY_SIZE(emoji_all), c));
+  return c >= 0x80 && (intable(emoji_all, ARRAY_SIZE(emoji_all), c));
 }
 
 // Generic conversion function for case operations.
diff --git a/src/nvim/tui/tui.c b/src/nvim/tui/tui.c
index 471a3fb85..37b34f646 100644
--- a/src/nvim/tui/tui.c
+++ b/src/nvim/tui/tui.c
@@ -2110,7 +2110,7 @@ static void augment_terminfo(TUIData *data, const char *term, long vte_version,
   }
 
   data->unibi_ext.set_cursor_color = unibi_find_ext_str(ut, "Cs");
-  if (-1 == data->unibi_ext.set_cursor_color) {
+  // if (-1 == data->unibi_ext.set_cursor_color) {
     if (iterm || iterm_pretending_xterm) {
       // FIXME: Bypassing tmux like this affects the cursor colour globally, in
       // all panes, which is not particularly desirable.  A better approach
@@ -2123,7 +2123,7 @@ static void augment_terminfo(TUIData *data, const char *term, long vte_version,
       data->unibi_ext.set_cursor_color = (int)unibi_add_ext_str(ut, "ext.set_cursor_color",
                                                                 "\033]12;#%p1%06x\007");
     }
-  }
+  // }
   if (-1 != data->unibi_ext.set_cursor_color) {
     data->unibi_ext.reset_cursor_color = unibi_find_ext_str(ut, "Cr");
     if (-1 == data->unibi_ext.reset_cursor_color) {
