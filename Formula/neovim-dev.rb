class NeovimDev < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/17f3a3ae31d91944a5a4e56aa743745cff7fdf07.tar.gz"
  sha256 "659c50ba5996c33edf394fb88aa0d5692b02d42301d9742175ce7ae4c6920568"
  version "0.10.0-dev-1742+g17f3a3ae3"
  license "Apache-2.0"

  conflicts_with "neovim", because: "both install a `nvim` binary"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "gettext"
  depends_on "waltarix/customs/libtree-sitter"
  depends_on "waltarix/customs/libvterm"
  depends_on "waltarix/customs/luajit"

  uses_from_macos "unzip" => :build

  on_macos do
    depends_on "libiconv"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.1.0-r1/wcwidth9.h"
    sha256 "5afe09e6986233b517c05e4c82dbb228bb6ed64ba4be6fd7bf3185b7d3e72eb0"
  end

  patch :DATA

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "LDFLAGS", "-Wl,-s"

    resource("wcwidth9.h").stage(buildpath/"src/nvim")

    system "sh", buildpath/"scripts/download-unicode-files.sh"

    inreplace "cmake.deps/cmake/BuildLpeg.cmake", "${DEPS_INCLUDE_FLAGS}", "-I${LUAJIT_INCLUDE_DIR}"

    # Point system locations inside `HOMEBREW_PREFIX`.
    "src/nvim/os/stdpaths.c".tap do |file|
      inreplace file, "/etc/xdg/", "#{etc}/xdg/:\\0"

      if HOMEBREW_PREFIX.to_s != HOMEBREW_DEFAULT_PREFIX
        inreplace file, "/usr/local/share/:/usr/share/", "#{HOMEBREW_PREFIX}/share/:\\0"
      end
    end

    ENV.deparallelize

    system "cmake", "-S", "cmake.deps", "-B", ".deps", "-G", "Ninja",
                    "-DUSE_BUNDLED=OFF",
                    "-DUSE_BUNDLED_LIBUV=ON",
                    "-DUSE_BUNDLED_LPEG=ON",
                    "-DUSE_BUNDLED_LUV=ON",
                    "-DUSE_BUNDLED_MSGPACK=ON",
                    "-DUSE_BUNDLED_UNIBILIUM=ON",
                    *std_cmake_args
    system "cmake", "--build", ".deps"

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja",
                    "-DNVIM_VERSION_MEDIUM=v#{version}",
                    *std_cmake_args

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
index f0fd4c66e..47f66e45c 100755
--- a/scripts/download-unicode-files.sh
+++ b/scripts/download-unicode-files.sh
@@ -1,14 +1,15 @@
 #!/bin/sh
 
 set -e
-data_files="UnicodeData.txt CaseFolding.txt EastAsianWidth.txt"
+data_files="UnicodeData.txt CaseFolding.txt"
 emoji_files="emoji-data.txt"
 files="'$data_files $emoji_files'"
 
 UNIDIR_DEFAULT=src/unicode
-DOWNLOAD_URL_BASE_DEFAULT='http://unicode.org/Public'
+UNIDIR_VERSION=15.0.0
+DOWNLOAD_URL_BASE_DEFAULT="https://www.unicode.org/Public/$UNIDIR_VERSION/ucd"
 
-if test "$1" = '--help' ; then
+if test "$1" = '--help'; then
   echo 'Usage:'
   echo "  $0[ TARGET_DIRECTORY[ URL_BASE]]"
   echo
@@ -23,14 +24,13 @@ fi
 UNIDIR=${1:-$UNIDIR_DEFAULT}
 DOWNLOAD_URL_BASE=${2:-$DOWNLOAD_URL_BASE_DEFAULT}
 
-for filename in $data_files ; do
-  curl -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/UNIDATA/$filename"
-  git -C "$UNIDIR" add "$filename"
+for filename in $data_files; do
+  curl -# -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/$filename"
 done
 
-for filename in $emoji_files ; do
-  curl -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/UNIDATA/emoji/$filename"
-  git -C "$UNIDIR" add "$filename"
+for filename in $emoji_files; do
+  curl -# -L -o "$UNIDIR/$filename" "$DOWNLOAD_URL_BASE/emoji/$filename"
 done
 
-git -C "$UNIDIR" commit -m "feat: update unicode tables" .
+curl -# -L -o "$UNIDIR/EastAsianWidth.txt" \
+  "https://github.com/waltarix/localedata/releases/download/${UNIDIR_VERSION}-r5/EastAsianWidth.txt"
diff --git a/src/nvim/api/ui.c b/src/nvim/api/ui.c
index b73c026d5..9ab459d8b 100644
--- a/src/nvim/api/ui.c
+++ b/src/nvim/api/ui.c
@@ -933,9 +933,6 @@ void remote_ui_raw_line(UI *ui, Integer grid, Integer row, Integer startcol, Int
       char sc_buf[MAX_SCHAR_SIZE];
       schar_get(sc_buf, chunk[i]);
       remote_ui_put(ui, sc_buf);
-      if (utf_ambiguous_width(utf_ptr2char(sc_buf))) {
-        data->client_col = -1;  // force cursor update
-      }
     }
     if (endcol < clearcol) {
       remote_ui_cursor_goto(ui, row, endcol);
diff --git a/src/nvim/generators/gen_unicode_tables.lua b/src/nvim/generators/gen_unicode_tables.lua
index 9ad99c802..e6c3569b1 100644
--- a/src/nvim/generators/gen_unicode_tables.lua
+++ b/src/nvim/generators/gen_unicode_tables.lua
@@ -318,8 +318,7 @@ eaw_fp:close()
 
 local doublewidth = build_width_table(ut_fp, dataprops, widthprops,
                                       {W=true, F=true}, 'doublewidth')
-local ambiwidth = build_width_table(ut_fp, dataprops, widthprops,
-                                    {A=true}, 'ambiguous')
+local ambiwidth = {}
 
 local emoji_fp = io.open(emoji_fname, 'r')
 local emojiprops = parse_emoji_props(emoji_fp)
diff --git a/src/nvim/mbyte.c b/src/nvim/mbyte.c
index f2883cc5c..8c15fda9c 100644
--- a/src/nvim/mbyte.c
+++ b/src/nvim/mbyte.c
@@ -85,6 +85,8 @@ struct interval {
 #endif
 // uncrustify:on
 
+#include "wcwidth9.h"
+
 static const char e_list_item_nr_is_not_list[]
   = N_("E1109: List item %d is not a List");
 static const char e_list_item_nr_does_not_contain_3_numbers[]
@@ -475,33 +477,17 @@ static bool intable(const struct interval *table, size_t n_items, int c)
 ///       gen_unicode_tables.lua, which must be manually invoked as needed.
 int utf_char2cells(int c)
 {
-  // Use the value from setcellwidths() at 0x80 and higher, unless the
-  // character is not printable.
-  if (c >= 0x80 && vim_isprintc(c)) {
-    int n = cw_value(c);
-    if (n != 0) {
-      return n;
-    }
-  }
-
   if (c >= 0x100) {
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
-  } else if (c >= 0x80 && !vim_isprintc(c)) {
-    // Characters below 0x100 are influenced by 'isprint' option.
-    return 4;                   // unprintable, displays <xx>
+    return n;
   }
 
-  if (c >= 0x80 && *p_ambw == 'd'
-      && intable(ambiguous, ARRAY_SIZE(ambiguous), c)) {
-    return 2;
+  if (c >= 0x80 && !vim_isprintc(c)) {
+    // Characters below 0x100 are influenced by 'isprint' option.
+    return 4;                   // unprintable, displays <xx>
   }
 
   return 1;
@@ -1135,12 +1121,6 @@ int utf_class_tab(const int c, const uint64_t *const chartab)
   return 2;
 }
 
-bool utf_ambiguous_width(int c)
-{
-  return c >= 0x80 && (intable(ambiguous, ARRAY_SIZE(ambiguous), c)
-                       || intable(emoji_all, ARRAY_SIZE(emoji_all), c));
-}
-
 // Generic conversion function for case operations.
 // Return the converted equivalent of "a", which is a UCS-4 character.  Use
 // the given conversion "table".  Uses binary search on "table".
diff --git a/src/nvim/tui/tui.c b/src/nvim/tui/tui.c
index c71eb633e..7f6333043 100644
--- a/src/nvim/tui/tui.c
+++ b/src/nvim/tui/tui.c
@@ -900,8 +900,7 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
 
   char buf[MAX_SCHAR_SIZE];
   schar_get(buf, cell->data);
-  bool is_ambiwidth = utf_ambiguous_width(utf_ptr2char(buf));
-  if (is_ambiwidth && is_doublewidth) {
+  if (is_doublewidth) {
     // Clear the two screen cells.
     // If the character is single-width in the host terminal it won't change the second cell.
     update_attrs(tui, cell->attr);
@@ -910,11 +909,6 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
   }
 
   print_cell(tui, buf, cell->attr);
-
-  if (is_ambiwidth) {
-    // Force repositioning cursor after printing an ambiguous-width character.
-    grid->row = -1;
-  }
 }
 
 static void clear_region(TUIData *tui, int top, int bot, int left, int right, int attr_id)
