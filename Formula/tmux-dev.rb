class TmuxDev < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/archive/b55f34029ac05474dfd993c187b9c61bbcd4e1a1.tar.gz"
  sha256 "8e5409724cad9c5c906772450af07e5428331e84dc5a4ebdc9f77195c07a042f"
  version "3.4-82+gb55f3402"
  license "ISC"

  conflicts_with "tmux", because: "both install a `tmux` binary"

  depends_on "bison" => :build
  depends_on "pkg-config" => :build
  depends_on "jemalloc"
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/f5d53239f7658f8e8fbaf02535cc369009c436d6/completions/tmux"
    sha256 "b5f7bbd78f9790026bbff16fc6e3fe4070d067f58f943e156bd1a8c3c99f6a6f"
  end

  patch :DATA

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --disable-utf8proc
    ]

    ncurses = Formula["ncurses"]
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    ENV.append "LDFLAGS", "-lresolv"
    system "./autogen.sh"
    system "./configure", *args

    system "make", "install"

    (libexec/"bin").install bin/"tmux"
    (bin/"tmux").write_env_script libexec/"bin/tmux",
                                  ld_preload => Formula["jemalloc"].lib/shared_library("libjemalloc")

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats
    <<~EOS
      Example configuration has been installed to:
        #{opt_pkgshare}

      To prevent jemalloc from being injected into child processes,
      add the following to your tmux.conf:
        set-environment -g -r #{ld_preload}
    EOS
  end

  def ld_preload
    on_macos do
      return :DYLD_INSERT_LIBRARIES
    end
    on_linux do
      return :LD_PRELOAD
    end
  end

  test do
    system bin/"tmux", "-V"

    require "pty"

    socket = testpath/tap.user
    PTY.spawn bin/"tmux", "-S", socket, "-f", "/dev/null"
    sleep 10

    assert_predicate socket, :exist?
    assert_predicate socket, :socket?
    assert_equal "no server running on #{socket}", shell_output("#{bin}/tmux -S#{socket} list-sessions 2>&1", 1).chomp
  end
end

__END__
diff --git a/Makefile.am b/Makefile.am
index 14d8874b..19a92956 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -223,6 +223,13 @@ fuzz_input_fuzzer_LDFLAGS = $(FUZZING_LIBS)
 fuzz_input_fuzzer_LDADD = $(LDADD) $(tmux_OBJECTS)
 endif
 
+BUILT_SOURCES = wcwidth9.h
+
+wcwidth9.h:
+	curl -sL \
+		"https://github.com/waltarix/localedata/releases/download/15.0.0-r4/wcwidth9.h" \
+		> $@
+
 # Install tmux.1 in the right format.
 install-exec-hook:
 	if test x@MANFORMAT@ = xmdoc; then \
diff --git a/configure.ac b/configure.ac
index 8e846042..60a2300a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,6 +1,6 @@
 # configure.ac
 
-AC_INIT([tmux], next-3.4)
+AC_INIT([tmux], 3.4-82+gb55f3402)
 AC_PREREQ([2.60])
 
 AC_CONFIG_AUX_DIR(etc)
diff --git a/log.c b/log.c
index 0e0d1d1a..cb374cb1 100644
--- a/log.c
+++ b/log.c
@@ -121,20 +121,6 @@ log_vwrite(const char *msg, va_list ap, const char *prefix)
 	free(out);
 }
 
-/* Log a debug message. */
-void
-log_debug(const char *msg, ...)
-{
-	va_list	ap;
-
-	if (log_file == NULL)
-		return;
-
-	va_start(ap, msg);
-	log_vwrite(msg, ap, "");
-	va_end(ap);
-}
-
 /* Log a critical error with error string and die. */
 __dead void
 fatal(const char *msg, ...)
diff --git a/popup.c b/popup.c
index f5c6a37c..e29394f4 100644
--- a/popup.c
+++ b/popup.c
@@ -259,6 +259,8 @@ popup_draw_cb(struct client *c, void *data, struct screen_redraw_ctx *rctx)
 	}
 	c->overlay_check = popup_check_cb;
 	c->overlay_data = pd;
+
+    screen_free(&s);
 }
 
 static void
diff --git a/screen-write.c b/screen-write.c
index b82a43dc..9d7b410a 100644
--- a/screen-write.c
+++ b/screen-write.c
@@ -2027,7 +2027,7 @@ screen_write_combine(struct screen_write_ctx *ctx, const struct utf8_data *ud,
 	    memcmp(ud->data, "\357\270\217", 3) == 0) {
 		grid_view_set_padding(gd, (*xx) + 1, s->cy);
 		gc.data.width = 2;
-		width += 2;
+		width = 2;
 	}
 
 	/* Set the new cell. */
diff --git a/tmux.h b/tmux.h
index ff77f780..f2c70f13 100644
--- a/tmux.h
+++ b/tmux.h
@@ -71,6 +71,8 @@ struct tmuxpeer;
 struct tmuxproc;
 struct winlink;
 
+#define log_debug(msg, ...)
+
 /* Default configuration files and socket paths. */
 #ifndef TMUX_CONF
 #define TMUX_CONF "/etc/tmux.conf:~/.tmux.conf"
diff --git a/utf8.c b/utf8.c
index 042ddf89..578c6256 100644
--- a/utf8.c
+++ b/utf8.c
@@ -26,6 +26,8 @@
 
 #include "tmux.h"
 
+#include "wcwidth9.h"
+
 struct utf8_item {
 	RB_ENTRY(utf8_item)	index_entry;
 	u_int			index;
@@ -229,22 +231,8 @@ utf8_width(struct utf8_data *ud, int *width)
 	case 0:
 		return (UTF8_ERROR);
 	}
-	log_debug("UTF-8 %.*s is %08X", (int)ud->size, ud->data, (u_int)wc);
-#ifdef HAVE_UTF8PROC
-	*width = utf8proc_wcwidth(wc);
-	log_debug("utf8proc_wcwidth(%08X) returned %d", (u_int)wc, *width);
-#else
-	*width = wcwidth(wc);
-	log_debug("wcwidth(%08X) returned %d", (u_int)wc, *width);
-	if (*width < 0) {
-		/*
-		 * C1 control characters are nonprintable, so they are always
-		 * zero width.
-		 */
-		*width = (wc >= 0x80 && wc <= 0x9f) ? 0 : 1;
-	}
-#endif
-	if (*width >= 0 && *width <= 0xff)
+	*width = wcwidth9(wc);
+	if (*width >= 0)
 		return (UTF8_DONE);
 	return (UTF8_ERROR);
 }
