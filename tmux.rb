class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux.git",
      revision: "5306bb0db79b4cc0b8e620bfe52e8fed446a101c"
  version "3.2-rc3"
  license "ISC"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  bottle :unneeded

  if OS.linux?
    depends_on "bison" => :build
    depends_on "jemalloc"
  else
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/f5d53239f7658f8e8fbaf02535cc369009c436d6/completions/tmux"
    sha256 "b5f7bbd78f9790026bbff16fc6e3fe4070d067f58f943e156bd1a8c3c99f6a6f"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/13.0.0-r1/wcwidth9.h"
    sha256 "f00b5d73a1bb266c13bae2f9d758eaec59080ad8579cebe7d649ae125b28f9f1"
  end

  patch :DATA

  def install
    system "sh", "autogen.sh"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    buildpath.install resource("wcwidth9.h")

    on_linux do
      ENV.append "LIBS", "-ljemalloc"
    end

    ncurses = Formula["ncurses"]
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats
    <<~EOS
      Example configuration has been installed to:
        #{opt_pkgshare}
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end

__END__
diff --git a/log.c b/log.c
index f87cab92..1686e2fe 100644
--- a/log.c
+++ b/log.c
@@ -124,20 +124,6 @@ log_vwrite(const char *msg, va_list ap)
 	free(fmt);
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
-	log_vwrite(msg, ap);
-	va_end(ap);
-}
-
 /* Log a critical error with error string and die. */
 __dead void
 fatal(const char *msg, ...)
diff --git a/popup.c b/popup.c
index 0ad20c5f..1f77482a 100644
--- a/popup.c
+++ b/popup.c
@@ -192,6 +192,8 @@ popup_draw_cb(struct client *c, __unused struct screen_redraw_ctx *ctx0)
 		    &grid_default_cell, NULL);
 	}
 	c->overlay_check = popup_check_cb;
+
+    screen_free(&s);
 }
 
 static void
diff --git a/tmux.h b/tmux.h
index 44ba53f5..e01056e2 100644
--- a/tmux.h
+++ b/tmux.h
@@ -66,6 +66,8 @@ struct tmuxpeer;
 struct tmuxproc;
 struct winlink;
 
+#define log_debug(msg, ...)
+
 /* Client-server protocol version. */
 #define PROTOCOL_VERSION 8
 
diff --git a/tty-acs.c b/tty-acs.c
index 63eccb93..da9205c9 100644
--- a/tty-acs.c
+++ b/tty-acs.c
@@ -44,10 +44,10 @@ static const struct tty_acs_entry tty_acs_table[] = {
 	{ 'g', "\302\261" },		/* plus/minus */
 	{ 'h', "\342\220\244" },
 	{ 'i', "\342\220\213" },
-	{ 'j', "\342\224\230" },	/* lower right corner */
-	{ 'k', "\342\224\220" },	/* upper right corner */
-	{ 'l', "\342\224\214" },	/* upper left corner */
-	{ 'm', "\342\224\224" },	/* lower left corner */
+	{ 'j', "\342\225\257" },	/* lower right corner */
+	{ 'k', "\342\225\256" },	/* upper right corner */
+	{ 'l', "\342\225\255" },	/* upper left corner */
+	{ 'm', "\342\225\260" },	/* lower left corner */
 	{ 'n', "\342\224\274" },	/* large plus or crossover */
 	{ 'o', "\342\216\272" },	/* scan line 1 */
 	{ 'p', "\342\216\273" },	/* scan line 3 */
@@ -80,13 +80,13 @@ static const struct tty_acs_reverse_entry tty_acs_reverse3[] = {
 	{ "\342\224\201", 'q' },
 	{ "\342\224\202", 'x' },
 	{ "\342\224\203", 'x' },
-	{ "\342\224\214", 'l' },
+	{ "\342\225\255", 'l' },
 	{ "\342\224\217", 'k' },
-	{ "\342\224\220", 'k' },
+	{ "\342\225\256", 'k' },
 	{ "\342\224\223", 'l' },
-	{ "\342\224\224", 'm' },
+	{ "\342\225\260", 'm' },
 	{ "\342\224\227", 'm' },
-	{ "\342\224\230", 'j' },
+	{ "\342\225\257", 'j' },
 	{ "\342\224\233", 'j' },
 	{ "\342\224\234", 't' },
 	{ "\342\224\243", 't' },
diff --git a/utf8.c b/utf8.c
index 458363b8..1dfd327d 100644
--- a/utf8.c
+++ b/utf8.c
@@ -26,6 +26,8 @@
 
 #include "tmux.h"
 
+#include "wcwidth9.h"
+
 struct utf8_item {
 	RB_ENTRY(utf8_item)	index_entry;
 	u_int			index;
@@ -225,10 +227,10 @@ utf8_width(struct utf8_data *ud, int *width)
 	case 0:
 		return (UTF8_ERROR);
 	}
-	*width = wcwidth(wc);
+	*width = wcwidth9(wc);
 	if (*width >= 0 && *width <= 0xff)
 		return (UTF8_DONE);
-	log_debug("UTF-8 %.*s, wcwidth() %d", (int)ud->size, ud->data, *width);
+	log_debug("UTF-8 %.*s, wcwidth9() %d", (int)ud->size, ud->data, *width);
 
 #ifndef __OpenBSD__
 	/*
