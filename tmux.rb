class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux.git",
    tag: "3.2-rc"
  license "ISC"

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
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
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

    ENV.append "LIBS", "-ljemalloc" if OS.linux?

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
index 6f2ab101..5afb1082 100644
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
index 67951215..5e470be4 100644
--- a/tmux.h
+++ b/tmux.h
@@ -66,6 +66,8 @@ struct tmuxpeer;
 struct tmuxproc;
 struct winlink;
 
+#define log_debug(msg, ...)
+
 /* Client-server protocol version. */
 #define PROTOCOL_VERSION 8
 
diff --git a/utf8.c b/utf8.c
index e640d845..c165ba17 100644
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
