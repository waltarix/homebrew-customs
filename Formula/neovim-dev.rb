class NeovimDev < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/bc66b755f61ba0e3383177b2866e05557ffa3966.tar.gz"
  sha256 "8aecfdda388aef193dc207254bb08ef94c3bdb20e5d259ace72136e938d262a3"
  version "0.10.0-dev-10+gbc66b755f"
  license "Apache-2.0"

  conflicts_with "neovim", because: "both install a `nvim` binary"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "gettext"
  depends_on "msgpack"
  depends_on "waltarix/customs/libtree-sitter"
  depends_on "waltarix/customs/libvterm"
  depends_on "waltarix/customs/luajit"

  uses_from_macos "unzip" => :build

  on_macos do
    depends_on "libiconv"
  end

  # Keep resources updated according to:
  # https://github.com/neovim/neovim/blob/v#{version}/cmake.deps/cmake/BuildLuarocks.cmake

  resource "mpack" do
    url "https://github.com/libmpack/libmpack-lua/releases/download/1.0.10/libmpack-lua-1.0.10.tar.gz"
    sha256 "18e202473c9a255f1d2261b019874522a4f1c6b6f989f80da93d7335933e8119"
  end

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.2-1.src.rock"
    sha256 "e0d0d687897f06588558168eeb1902ac41a11edd1b58f1aa61b99d0ea0abbfbc"
  end

  resource "luarocks" do
    url "https://luarocks.org/releases/luarocks-3.9.2.tar.gz"
    sha256 "bca6e4ecc02c203e070acdb5f586045d45c078896f6236eb46aa33ccd9b94edb"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.0.0-r4/wcwidth9.h"
    sha256 "81974cfee64faece46162923a3ed3a70b9dfb7723005103730718bf2dded6ab5"
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
        mpack/mpack-1.0.10-0.rockspec
        lpeg/lpeg-1.0.2-1.src.rock
      ].each do |rock|
        dir, rock = rock.split("/")
        cd dir do
          output = Utils.safe_popen_read("luarocks", "unpack", lua_path, rock, "--tree=#{buildpath}/deps-build")
          unpack_dir = output.split("\n")[-2]
          cd unpack_dir do
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

    ENV.deparallelize

    system "cmake", "-S", "cmake.deps", "-B", ".deps", "-G", "Ninja",
                    "-DUSE_BUNDLED=OFF",
                    "-DUSE_BUNDLED_LIBTERMKEY=ON",
                    "-DUSE_BUNDLED_LIBUV=ON",
                    "-DUSE_BUNDLED_LUV=ON",
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
diff --git a/runtime/lua/vim/lsp.lua b/runtime/lua/vim/lsp.lua
index 2d39f2d45..b72edede4 100644
--- a/runtime/lua/vim/lsp.lua
+++ b/runtime/lua/vim/lsp.lua
@@ -59,6 +59,7 @@ lsp._request_name_to_capability = {
   ['textDocument/references'] = { 'referencesProvider' },
   ['textDocument/rangeFormatting'] = { 'documentRangeFormattingProvider' },
   ['textDocument/formatting'] = { 'documentFormattingProvider' },
+  ['textDocument/diagnostic'] = { 'diagnosticProvider' },
   ['textDocument/completion'] = { 'completionProvider' },
   ['textDocument/documentHighlight'] = { 'documentHighlightProvider' },
   ['textDocument/semanticTokens/full'] = { 'semanticTokensProvider' },
@@ -607,6 +608,9 @@ do
           },
           contentChanges = changes,
         })
+        vim.schedule(function()
+          vim.lsp.diagnostic.pull_diagnostic(bufnr, client)
+        end)
       end
     end
   end
@@ -722,6 +726,8 @@ local function text_document_did_open_handler(bufnr, client)
   client.notify('textDocument/didOpen', params)
   util.buf_versions[bufnr] = params.textDocument.version
 
+  vim.lsp.diagnostic.pull_diagnostic(bufnr, client)
+
   -- Next chance we get, we should re-do the diagnostics
   vim.schedule(function()
     -- Protect against a race where the buffer disappears
diff --git a/runtime/lua/vim/lsp/diagnostic.lua b/runtime/lua/vim/lsp/diagnostic.lua
index 3efa5c51f..fd18323b7 100644
--- a/runtime/lua/vim/lsp/diagnostic.lua
+++ b/runtime/lua/vim/lsp/diagnostic.lua
@@ -236,6 +236,25 @@ function M.on_publish_diagnostics(_, result, ctx, config)
   vim.diagnostic.set(namespace, bufnr, diagnostic_lsp_to_vim(diagnostics, bufnr, client_id))
 end
 
+function M.pull_diagnostic(bufnr, client)
+  if not client.supports_method('textDocument/diagnostic') then
+    return
+  end
+
+  client.request(
+    'textDocument/diagnostic',
+    { textDocument = { uri = vim.uri_from_bufnr(bufnr) } },
+    function(err, result)
+      if err or result == nil then
+        return
+      end
+
+      local namespace = M.get_namespace(client.id)
+      vim.diagnostic.set(namespace, bufnr, diagnostic_lsp_to_vim(result.items, bufnr, client.id))
+    end
+  )
+end
+
 --- Clear diagnostics and diagnostic cache.
 ---
 --- Diagnostic producers should prefer |vim.diagnostic.reset()|. However,
diff --git a/runtime/lua/vim/lsp/protocol.lua b/runtime/lua/vim/lsp/protocol.lua
index f4489ad17..04372cbfa 100644
--- a/runtime/lua/vim/lsp/protocol.lua
+++ b/runtime/lua/vim/lsp/protocol.lua
@@ -807,6 +807,10 @@ function protocol.make_client_capabilities()
           end)(),
         },
       },
+      diagnostic = {
+        dynamicRegistration = false,
+        relatedDocumentSupport = false,
+      },
       callHierarchy = {
         dynamicRegistration = false,
       },
diff --git a/scripts/download-unicode-files.sh b/scripts/download-unicode-files.sh
index f0fd4c66e..c4938a537 100755
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
+  "https://github.com/waltarix/localedata/releases/download/${UNIDIR_VERSION}-r4/EastAsianWidth.txt"
diff --git a/src/nvim/api/ui.c b/src/nvim/api/ui.c
index edf13b073..f166450c8 100644
--- a/src/nvim/api/ui.c
+++ b/src/nvim/api/ui.c
@@ -874,9 +874,6 @@ void remote_ui_raw_line(UI *ui, Integer grid, Integer row, Integer startcol, Int
       remote_ui_cursor_goto(ui, row, startcol + i);
       remote_ui_highlight_set(ui, attrs[i]);
       remote_ui_put(ui, chunk[i]);
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
index ab787524a..4d671833a 100644
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
@@ -477,33 +479,17 @@ static bool intable(const struct interval *table, size_t n_items, int c)
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
@@ -1162,12 +1148,6 @@ int utf_class_tab(const int c, const uint64_t *const chartab)
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
index df7c87ad6..f60ddc756 100644
--- a/src/nvim/tui/tui.c
+++ b/src/nvim/tui/tui.c
@@ -836,8 +836,7 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
 
   cursor_goto(tui, row, col);
 
-  bool is_ambiwidth = utf_ambiguous_width(utf_ptr2char(cell->data));
-  if (is_ambiwidth && is_doublewidth) {
+  if (is_doublewidth) {
     // Clear the two screen cells.
     // If the character is single-width in the host terminal it won't change the second cell.
     update_attrs(tui, cell->attr);
@@ -846,11 +845,6 @@ static void print_cell_at_pos(TUIData *tui, int row, int col, UCell *cell, bool
   }
 
   print_cell(tui, cell);
-
-  if (is_ambiwidth) {
-    // Force repositioning cursor after printing an ambiguous-width character.
-    grid->row = -1;
-  }
 }
 
 static void clear_region(TUIData *tui, int top, int bot, int left, int right, int attr_id)
