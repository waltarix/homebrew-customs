class TmuxDev < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/archive/381c00a74ea1eb136a97c86da9a7713190b10a62.tar.gz"
  sha256 "395c43d406e9a83641210935de5382f59714a5f7aacb6c3b20d433d496e07994"
  version "3.4-149-g381c00a7"
  license "ISC"

  conflicts_with "tmux", because: "both install a `tmux` binary"

  depends_on "bison" => :build
  depends_on "pkg-config" => :build
  depends_on "jemalloc"
  depends_on "libevent"
  depends_on "ncurses"

  on_macos do
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

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
    ENV.append_to_cflags "-flto"
    ENV.append_to_cflags "-ffat-lto-objects"
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
index 8e5f72b1..4c34b725 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -228,6 +228,13 @@ fuzz_input_fuzzer_LDFLAGS = $(FUZZING_LIBS)
 fuzz_input_fuzzer_LDADD = $(LDADD) $(tmux_OBJECTS)
 endif
 
+BUILT_SOURCES = wcwidth9.h
+
+wcwidth9.h:
+	curl -sL \
+		"https://github.com/waltarix/localedata/releases/download/15.1.0-r1/wcwidth9.h" \
+		> $@
+
 # Install tmux.1 in the right format.
 install-exec-hook:
 	if test x@MANFORMAT@ = xmdoc; then \
diff --git a/configure.ac b/configure.ac
index 020f21e5..1400f774 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,6 +1,6 @@
 # configure.ac
 
-AC_INIT([tmux], next-3.4)
+AC_INIT([tmux], 3.3-149-g381c00a7)
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
diff --git a/tmux.h b/tmux.h
index 53f73b20..990d9202 100644
--- a/tmux.h
+++ b/tmux.h
@@ -77,6 +77,8 @@ struct tmuxpeer;
 struct tmuxproc;
 struct winlink;
 
+#define log_debug(msg, ...)
+
 /* Default configuration files and socket paths. */
 #ifndef TMUX_CONF
 #define TMUX_CONF "/etc/tmux.conf:~/.tmux.conf"
diff --git a/utf8.c b/utf8.c
index 5053e459..d1bfb16e 100644
--- a/utf8.c
+++ b/utf8.c
@@ -26,6 +26,8 @@
 
 #include "tmux.h"
 
+#include "wcwidth9.h"
+
 static const wchar_t utf8_force_wide[] = {
 	0x0261D,
 	0x026F9,
@@ -409,21 +411,8 @@ utf8_width(struct utf8_data *ud, int *width)
 		*width = 2;
 		return (UTF8_DONE);
 	}
-#ifdef HAVE_UTF8PROC
-	*width = utf8proc_wcwidth(wc);
-	log_debug("utf8proc_wcwidth(%05X) returned %d", (u_int)wc, *width);
-#else
-	*width = wcwidth(wc);
-	log_debug("wcwidth(%05X) returned %d", (u_int)wc, *width);
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
