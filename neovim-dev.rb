class NeovimDev < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/c19bd47c0a2e3cc77d7f5e41ed184edb41685bd3.tar.gz"
  sha256 "e90a22462eeba1bda5ffd70d6e0b17e2a0aa2c38ee95be5e2fdd1f362fff260b"
  version "0.9.0-dev-635-gc19bd47c0"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  conflicts_with "neovim", because: "both install a `nvim` binary"

  depends_on "cmake" => :build
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

  uses_from_macos "unzip" => :build

  on_linux do
    depends_on "libnsl"
  end

  # Keep resources updated according to:
  # https://github.com/neovim/neovim/blob/v#{version}/cmake.deps/cmake/BuildLuarocks.cmake

  resource "mpack" do
    url "https://github.com/libmpack/libmpack-lua/releases/download/1.0.9/libmpack-lua-1.0.9.tar.gz"
    sha256 "0fd07e709c3f6f201c2ffc9f77cef1b303b02c12413f0c15670a32bf6c959e9e"
  end

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.2-1.src.rock"
    sha256 "e0d0d687897f06588558168eeb1902ac41a11edd1b58f1aa61b99d0ea0abbfbc"
  end

  resource "luarocks" do
    url "https://luarocks.org/releases/luarocks-3.9.1.tar.gz"
    sha256 "ffafd83b1c42aa38042166a59ac3b618c838ce4e63f4ace9d961a5679ef58253"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.0.0-r1/wcwidth9.h"
    sha256 "aa242ec09a43dc360d8ccf971b55a5dc9910fec27db3822f3abc0ee04b06cc5c"
  end

  patch :DATA

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "LDFLAGS", "-Wl,-s"

    resource("luarocks").stage do
      system "./configure", "--prefix=#{buildpath}/luarocks",
                            "--rocks-tree=#{HOMEBREW_PREFIX}"
      system "make", "install"

      ENV.append_path "PATH", buildpath/"luarocks/bin"
    end

    resource("wcwidth9.h").stage(buildpath/"src/nvim")

    rocks = resources.map(&:name).to_set - ["luarocks", "wcwidth9.h"]
    rocks.each do |r|
      resource(r).stage(buildpath/"deps-build/build/src"/r)
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
diff --git a/runtime/plugin/matchparen.vim b/runtime/plugin/matchparen.vim
index 3982489b9..35508a3db 100644
--- a/runtime/plugin/matchparen.vim
+++ b/runtime/plugin/matchparen.vim
@@ -19,7 +19,8 @@ endif
 
 augroup matchparen
   " Replace all matchparen autocommands
-  autocmd! CursorMoved,CursorMovedI,WinEnter,BufWinEnter,WinScrolled * call s:Highlight_Matching_Pair()
+  autocmd! CursorMoved,CursorMovedI,WinEnter,WinScrolled * call s:Highlight_Matching_Pair()
+  autocmd! BufWinEnter * call s:Highlight_Matching_Pair('bwe')
   autocmd! WinLeave,BufLeave * call s:Remove_Matches()
   if exists('##TextChanged')
     autocmd! TextChanged,TextChangedI * call s:Highlight_Matching_Pair()
@@ -36,7 +37,11 @@ set cpo-=C
 
 " The function that is invoked (very often) to define a ":match" highlighting
 " for any matching paren.
-func s:Highlight_Matching_Pair()
+func s:Highlight_Matching_Pair(...)
+  if get(a:, 1, '') == 'bwe' && has_key(v:lua.vim.api.nvim_win_get_config(0), 'zindex')
+    return
+  endif
+
   " Remove any previous match.
   call s:Remove_Matches()
 
diff --git a/scripts/download-unicode-files.sh b/scripts/download-unicode-files.sh
index f0fd4c66e..54f2a5e4b 100755
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
+DOWNLOAD_URL_BASE_DEFAULT="https://unicode.org/Public/$UNIDIR_VERSION/ucd"
 
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
index 32b294c0c..1101ce92f 100644
--- a/src/nvim/api/ui.c
+++ b/src/nvim/api/ui.c
@@ -868,9 +868,6 @@ void remote_ui_raw_line(UI *ui, Integer grid, Integer row, Integer startcol, Int
       remote_ui_cursor_goto(ui, row, startcol + i);
       remote_ui_highlight_set(ui, attrs[i]);
       remote_ui_put(ui, (const char *)chunk[i]);
-      if (utf_ambiguous_width(utf_ptr2char((char *)chunk[i]))) {
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
index f48955c90..83cae3049 100644
--- a/src/nvim/mbyte.c
+++ b/src/nvim/mbyte.c
@@ -90,6 +90,8 @@ struct interval {
 #endif
 // uncrustify:on
 
+#include "wcwidth9.h"
+
 static char e_list_item_nr_is_not_list[]
   = N_("E1109: List item %d is not a List");
 static char e_list_item_nr_does_not_contain_3_numbers[]
@@ -483,30 +485,16 @@ static bool intable(const struct interval *table, size_t n_items, int c)
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
 
@@ -1173,12 +1161,6 @@ int utf_class_tab(const int c, const uint64_t *const chartab)
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
index 44f671803..17873a9bb 100644
--- a/src/nvim/tui/tui.c
+++ b/src/nvim/tui/tui.c
@@ -848,8 +848,7 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
 
   cursor_goto(tui, row, col);
 
-  bool is_ambiwidth = utf_ambiguous_width(utf_ptr2char(cell->data));
-  if (is_ambiwidth && is_doublewidth) {
+  if (is_doublewidth) {
     // Clear the two screen cells.
     // If the character is single-width in the host terminal it won't change the second cell.
     update_attrs(tui, cell->attr);
@@ -858,11 +857,6 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
   }
 
   print_cell(tui, cell);
-
-  if (is_ambiwidth) {
-    // Force repositioning cursor after printing an ambiguous-width character.
-    grid->row = -1;
-  }
 }
 
 static void clear_region(TUIData *tui, int top, int bot, int left, int right, int attr_id)
