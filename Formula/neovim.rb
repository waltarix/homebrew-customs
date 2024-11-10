class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/refs/tags/v0.10.2.tar.gz"
  sha256 "546cb2da9fffbb7e913261344bbf4cf1622721f6c5a67aa77609e976e78b8e89"
  license "Apache-2.0"
  revision 1

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

    # Point system locations inside `HOMEBREW_PREFIX`.
    inreplace "src/nvim/os/stdpaths.c" do |s|
      s.gsub! "/etc/xdg/", "#{etc}/xdg/:\\0"

      if HOMEBREW_PREFIX.to_s != HOMEBREW_DEFAULT_PREFIX
        s.gsub! "/usr/local/share/:/usr/share/", "#{HOMEBREW_PREFIX}/share/:\\0"
      end
    end

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

  def caveats
    return if latest_head_version.blank?

    <<~EOS
      HEAD installs of Neovim do not include any tree-sitter parsers.
      You can use the `nvim-treesitter` plugin to install them.
    EOS
  end

  test do
    refute_match "dirty", shell_output("#{bin}/nvim --version")
    (testpath/"test.txt").write("Hello World from Vim!!")
    system bin/"nvim", "--headless", "-i", "NONE", "-u", "NONE",
                       "+s/Vim/Neovim/g", "+wq", "test.txt"
    assert_equal "Hello World from Neovim!!", (testpath/"test.txt").read.chomp
  end
end

__END__
diff --git a/scripts/download-unicode-files.sh b/scripts/download-unicode-files.sh
index f0fd4c66ea..c84753796e 100755
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
+UNIDIR_VERSION=15.1.0
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
+  "https://github.com/waltarix/localedata/releases/download/${UNIDIR_VERSION}-r1/EastAsianWidth.txt"
diff --git a/src/nvim/api/ui.c b/src/nvim/api/ui.c
index 852b8b9b48..7207bb9e7a 100644
--- a/src/nvim/api/ui.c
+++ b/src/nvim/api/ui.c
@@ -848,9 +848,6 @@ void remote_ui_raw_line(RemoteUI *ui, Integer grid, Integer row, Integer startco
       char sc_buf[MAX_SCHAR_SIZE];
       schar_get(sc_buf, chunk[i]);
       remote_ui_put(ui, sc_buf);
-      if (utf_ambiguous_width(utf_ptr2char(sc_buf))) {
-        ui->client_col = -1;  // force cursor update
-      }
     }
     if (endcol < clearcol) {
       remote_ui_cursor_goto(ui, row, endcol);
diff --git a/src/nvim/generators/gen_unicode_tables.lua b/src/nvim/generators/gen_unicode_tables.lua
index 6cedb5db50..92840147ce 100644
--- a/src/nvim/generators/gen_unicode_tables.lua
+++ b/src/nvim/generators/gen_unicode_tables.lua
@@ -312,7 +312,7 @@ eaw_fp:close()
 
 local doublewidth =
   build_width_table(ut_fp, dataprops, widthprops, { W = true, F = true }, 'doublewidth')
-local ambiwidth = build_width_table(ut_fp, dataprops, widthprops, { A = true }, 'ambiguous')
+local ambiwidth = {}
 
 local emoji_fp = io.open(emoji_fname, 'r')
 local emojiprops = parse_emoji_props(emoji_fp)
diff --git a/src/nvim/mbyte.c b/src/nvim/mbyte.c
index e47901fde4..4249410157 100644
--- a/src/nvim/mbyte.c
+++ b/src/nvim/mbyte.c
@@ -87,6 +87,8 @@ struct interval {
 #endif
 // uncrustify:on
 
+#include "wcwidth9.h"
+
 static const char e_list_item_nr_is_not_list[]
   = N_("E1109: List item %d is not a List");
 static const char e_list_item_nr_does_not_contain_3_numbers[]
@@ -483,25 +485,18 @@ int utf_char2cells(int c)
     return 1;
   }
 
-  if (!vim_isprintc(c)) {
-    assert(c <= 0xFFFF);
-    // unprintable is displayed either as <xx> or <xxxx>
-    return c > 0xFF ? 6 : 4;
-  }
-
-  int n = cw_value(c);
-  if (n != 0) {
+  if (c >= 0x100) {
+    int n = wcwidth9(c);
+    if (n < 0) {
+      // unprintable, displays <xxxx>
+      return 6;
+    }
     return n;
   }
 
-  if (intable(doublewidth, ARRAY_SIZE(doublewidth), c)) {
-    return 2;
-  }
-  if (p_emoji && intable(emoji_wide, ARRAY_SIZE(emoji_wide), c)) {
-    return 2;
-  }
-  if (*p_ambw == 'd' && intable(ambiguous, ARRAY_SIZE(ambiguous), c)) {
-    return 2;
+  if (!vim_isprintc(c)) {
+    // unprintable, displays <xx>
+    return 4;
   }
 
   return 1;
@@ -1276,12 +1271,6 @@ int utf_class_tab(const int c, const uint64_t *const chartab)
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
index 7a02bfca57..5ac2438647 100644
--- a/src/nvim/tui/tui.c
+++ b/src/nvim/tui/tui.c
@@ -998,11 +998,7 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
   char buf[MAX_SCHAR_SIZE];
   schar_get(buf, cell->data);
   int c = utf_ptr2char(buf);
-  bool is_ambiwidth = utf_ambiguous_width(c);
-  if (is_doublewidth && (is_ambiwidth || utf_char2cells(c) == 1)) {
-    // If the server used setcellwidths() to treat a single-width char as double-width,
-    // it needs to be treated like an ambiguous-width char.
-    is_ambiwidth = true;
+  if (is_doublewidth) {
     // Clear the two screen cells.
     // If the char is single-width in host terminal it won't change the second cell.
     update_attrs(tui, cell->attr);
@@ -1011,11 +1007,6 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
   }
 
   print_cell(tui, buf, cell->attr);
-
-  if (is_ambiwidth) {
-    // Force repositioning cursor after printing an ambiguous-width char.
-    grid->row = -1;
-  }
 }
 
 static void clear_region(TUIData *tui, int top, int bot, int left, int right, int attr_id)
