class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/waltarix/tmux/releases/download/3.3-rc-custom-r2/tmux-3.3-rc.tar.xz"
  sha256 "85ab88354af623dc057248ed3c6890e9457a6923a59c954858f0e4dd22df98be"
  license "ISC"
  revision 2

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

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

  patch :DATA

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    on_macos do
      args << "--disable-utf8proc"
    end

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
diff --git a/format.c b/format.c
index 178102cc..e6d5dac9 100644
--- a/format.c
+++ b/format.c
@@ -3327,7 +3327,7 @@ format_find(struct format_tree *ft, const char *key, int modifiers,
 	fte = format_table_get(key);
 	if (fte != NULL) {
 		value = fte->cb(ft);
-		if (fte->type == FORMAT_TABLE_TIME)
+		if (fte->type == FORMAT_TABLE_TIME && value != NULL)
 			t = ((struct timeval *)value)->tv_sec;
 		else
 			found = value;
diff --git a/input.c b/input.c
index 7a320c56..8a16281c 100644
--- a/input.c
+++ b/input.c
@@ -1646,7 +1646,7 @@ input_csi_dispatch_rm(struct input_ctx *ictx)
 			screen_write_mode_clear(sctx, MODE_INSERT);
 			break;
 		case 34:
-			screen_write_mode_set(sctx, MODE_BLINKING);
+			screen_write_mode_set(sctx, MODE_CURSOR_VERY_VISIBLE);
 			break;
 		default:
 			log_debug("%s: unknown '%c'", __func__, ictx->ch);
@@ -1682,7 +1682,7 @@ input_csi_dispatch_rm_private(struct input_ctx *ictx)
 			screen_write_mode_clear(sctx, MODE_WRAP);
 			break;
 		case 12:
-			screen_write_mode_clear(sctx, MODE_BLINKING);
+			screen_write_mode_clear(sctx, MODE_CURSOR_BLINKING);
 			break;
 		case 25:	/* TCEM */
 			screen_write_mode_clear(sctx, MODE_CURSOR);
@@ -1734,7 +1734,7 @@ input_csi_dispatch_sm(struct input_ctx *ictx)
 			screen_write_mode_set(sctx, MODE_INSERT);
 			break;
 		case 34:
-			screen_write_mode_clear(sctx, MODE_BLINKING);
+			screen_write_mode_clear(sctx, MODE_CURSOR_VERY_VISIBLE);
 			break;
 		default:
 			log_debug("%s: unknown '%c'", __func__, ictx->ch);
@@ -1771,7 +1771,7 @@ input_csi_dispatch_sm_private(struct input_ctx *ictx)
 			screen_write_mode_set(sctx, MODE_WRAP);
 			break;
 		case 12:
-			screen_write_mode_set(sctx, MODE_BLINKING);
+			screen_write_mode_set(sctx, MODE_CURSOR_BLINKING);
 			break;
 		case 25:	/* TCEM */
 			screen_write_mode_set(sctx, MODE_CURSOR);
diff --git a/screen.c b/screen.c
index 514c740e..3837c8f5 100644
--- a/screen.c
+++ b/screen.c
@@ -162,27 +162,27 @@ screen_set_cursor_style(struct screen *s, u_int style)
 		break;
 	case 1:
 		s->cstyle = SCREEN_CURSOR_BLOCK;
-		s->mode |= MODE_BLINKING;
+		s->mode |= MODE_CURSOR_BLINKING;
 		break;
 	case 2:
 		s->cstyle = SCREEN_CURSOR_BLOCK;
-		s->mode &= ~MODE_BLINKING;
+		s->mode &= ~MODE_CURSOR_BLINKING;
 		break;
 	case 3:
 		s->cstyle = SCREEN_CURSOR_UNDERLINE;
-		s->mode |= MODE_BLINKING;
+		s->mode |= MODE_CURSOR_BLINKING;
 		break;
 	case 4:
 		s->cstyle = SCREEN_CURSOR_UNDERLINE;
-		s->mode &= ~MODE_BLINKING;
+		s->mode &= ~MODE_CURSOR_BLINKING;
 		break;
 	case 5:
 		s->cstyle = SCREEN_CURSOR_BAR;
-		s->mode |= MODE_BLINKING;
+		s->mode |= MODE_CURSOR_BLINKING;
 		break;
 	case 6:
 		s->cstyle = SCREEN_CURSOR_BAR;
-		s->mode &= ~MODE_BLINKING;
+		s->mode &= ~MODE_CURSOR_BLINKING;
 		break;
 	}
 }
@@ -679,8 +679,10 @@ screen_mode_to_string(int mode)
 		strlcat(tmp, "MOUSE_STANDARD,", sizeof tmp);
 	if (mode & MODE_MOUSE_BUTTON)
 		strlcat(tmp, "MOUSE_BUTTON,", sizeof tmp);
-	if (mode & MODE_BLINKING)
-		strlcat(tmp, "BLINKING,", sizeof tmp);
+	if (mode & MODE_CURSOR_BLINKING)
+		strlcat(tmp, "CURSOR_BLINKING,", sizeof tmp);
+	if (mode & MODE_CURSOR_VERY_VISIBLE)
+		strlcat(tmp, "CURSOR_VERY_VISIBLE,", sizeof tmp);
 	if (mode & MODE_MOUSE_UTF8)
 		strlcat(tmp, "UTF8,", sizeof tmp);
 	if (mode & MODE_MOUSE_SGR)
diff --git a/tmux.h b/tmux.h
index 2bd98b01..811feda4 100644
--- a/tmux.h
+++ b/tmux.h
@@ -523,7 +523,7 @@ enum tty_code_code {
 #define MODE_WRAP 0x10
 #define MODE_MOUSE_STANDARD 0x20
 #define MODE_MOUSE_BUTTON 0x40
-#define MODE_BLINKING 0x80
+#define MODE_CURSOR_BLINKING 0x80
 #define MODE_MOUSE_UTF8 0x100
 #define MODE_MOUSE_SGR 0x200
 #define MODE_BRACKETPASTE 0x400
@@ -532,10 +532,12 @@ enum tty_code_code {
 #define MODE_ORIGIN 0x2000
 #define MODE_CRLF 0x4000
 #define MODE_KEXTENDED 0x8000
+#define MODE_CURSOR_VERY_VISIBLE 0x10000
 
 #define ALL_MODES 0xffffff
 #define ALL_MOUSE_MODES (MODE_MOUSE_STANDARD|MODE_MOUSE_BUTTON|MODE_MOUSE_ALL)
 #define MOTION_MOUSE_MODES (MODE_MOUSE_BUTTON|MODE_MOUSE_ALL)
+#define CURSOR_MODES (MODE_CURSOR|MODE_CURSOR_BLINKING|MODE_CURSOR_VERY_VISIBLE)
 
 /* A single UTF-8 character. */
 typedef u_int utf8_char;
diff --git a/tty.c b/tty.c
index ba58aa2b..82f04afb 100644
--- a/tty.c
+++ b/tty.c
@@ -658,12 +658,83 @@ tty_force_cursor_colour(struct tty *tty, const char *ccolour)
 	tty->ccolour = xstrdup(ccolour);
 }
 
+static void
+tty_update_cursor(struct tty *tty, int mode, int changed, struct screen *s)
+{
+	enum screen_cursor_style cstyle;
+
+	/* Set cursor colour if changed. */
+	if (s != NULL && strcmp(s->ccolour, tty->ccolour) != 0)
+		tty_force_cursor_colour(tty, s->ccolour);
+
+	/* If cursor is off, set as invisible. */
+	if (~mode & MODE_CURSOR) {
+		if (changed & MODE_CURSOR)
+			tty_putcode(tty, TTYC_CIVIS);
+		return;
+	}
+
+	/* Check if blinking or very visible flag changed or style changed. */
+	if (s == NULL)
+		cstyle = tty->cstyle;
+	else
+		cstyle = s->cstyle;
+	if ((changed & CURSOR_MODES) == 0 && cstyle == tty->cstyle)
+		return;
+
+	/*
+	 * Set cursor style. If an explicit style has been set with DECSCUSR,
+	 * set it if supported, otherwise send cvvis for blinking styles.
+	 *
+	 * If no style, has been set (SCREEN_CURSOR_DEFAULT), then send cvvis
+	 * if either the blinking or very visible flags are set.
+	 */
+	tty_putcode(tty, TTYC_CNORM);
+	switch (cstyle) {
+	case SCREEN_CURSOR_DEFAULT:
+		if (tty_term_has(tty->term, TTYC_SE))
+			tty_putcode(tty, TTYC_SE);
+		else
+			tty_putcode1(tty, TTYC_SS, 0);
+		if (mode & (MODE_CURSOR_BLINKING|MODE_CURSOR_VERY_VISIBLE))
+			tty_putcode(tty, TTYC_CVVIS);
+		break;
+	case SCREEN_CURSOR_BLOCK:
+		if (tty_term_has(tty->term, TTYC_SS)) {
+			if (mode & MODE_CURSOR_BLINKING)
+				tty_putcode1(tty, TTYC_SS, 1);
+			else
+				tty_putcode1(tty, TTYC_SS, 2);
+		} else if (mode & MODE_CURSOR_BLINKING)
+			tty_putcode(tty, TTYC_CVVIS);
+		break;
+	case SCREEN_CURSOR_UNDERLINE:
+		if (tty_term_has(tty->term, TTYC_SS)) {
+			if (mode & MODE_CURSOR_BLINKING)
+				tty_putcode1(tty, TTYC_SS, 3);
+			else
+				tty_putcode1(tty, TTYC_SS, 4);
+		} else if (mode & MODE_CURSOR_BLINKING)
+			tty_putcode(tty, TTYC_CVVIS);
+		break;
+	case SCREEN_CURSOR_BAR:
+		if (tty_term_has(tty->term, TTYC_SS)) {
+			if (mode & MODE_CURSOR_BLINKING)
+				tty_putcode1(tty, TTYC_SS, 5);
+			else
+				tty_putcode1(tty, TTYC_SS, 6);
+		} else if (mode & MODE_CURSOR_BLINKING)
+			tty_putcode(tty, TTYC_CVVIS);
+		break;
+	}
+	tty->cstyle = cstyle;
+ }
+
 void
 tty_update_mode(struct tty *tty, int mode, struct screen *s)
 {
-	struct client		*c = tty->client;
-	int			 changed;
-	enum screen_cursor_style cstyle = tty->cstyle;
+	struct client	*c = tty->client;
+	int		 changed;
 
 	if (tty->flags & TTY_NOCURSOR)
 		mode &= ~MODE_CURSOR;
@@ -676,85 +747,7 @@ tty_update_mode(struct tty *tty, int mode, struct screen *s)
 		    screen_mode_to_string(mode));
 	}
 
-	if (s != NULL) {
-		if (strcmp(s->ccolour, tty->ccolour) != 0)
-			tty_force_cursor_colour(tty, s->ccolour);
-		cstyle = s->cstyle;
-	}
-	if (~mode & MODE_CURSOR) {
-		/* Cursor now off - set as invisible. */
-		if (changed & MODE_CURSOR)
-			tty_putcode(tty, TTYC_CIVIS);
-	} else if ((changed & (MODE_CURSOR|MODE_BLINKING)) ||
-	    cstyle != tty->cstyle) {
-		/*
-		 * Cursor now on, blinking flag changed or style changed. Start
-		 * by setting the cursor to normal.
-		 */
-		tty_putcode(tty, TTYC_CNORM);
-		switch (cstyle) {
-		case SCREEN_CURSOR_DEFAULT:
-			/*
-			 * If the old style wasn't default, then reset it to
-			 * default.
-			 */
-			if (tty->cstyle != SCREEN_CURSOR_DEFAULT) {
-				if (tty_term_has(tty->term, TTYC_SE))
-					tty_putcode(tty, TTYC_SE);
-				else
-					tty_putcode1(tty, TTYC_SS, 0);
-			}
-
-			/* Set the cursor as very visible if necessary. */
-			if (mode & MODE_BLINKING)
-				tty_putcode(tty, TTYC_CVVIS);
-			break;
-		case SCREEN_CURSOR_BLOCK:
-			/*
-			 * Set style to either block blinking (1) or steady (2)
-			 * if supported, otherwise just check the blinking
-			 * flag.
-			 */
-			if (tty_term_has(tty->term, TTYC_SS)) {
-				if (mode & MODE_BLINKING)
-					tty_putcode1(tty, TTYC_SS, 1);
-				else
-					tty_putcode1(tty, TTYC_SS, 2);
-			} else if (mode & MODE_BLINKING)
-				tty_putcode(tty, TTYC_CVVIS);
-			break;
-		case SCREEN_CURSOR_UNDERLINE:
-			/*
-			 * Set style to either underline blinking (3) or steady
-			 * (4) if supported, otherwise just check the blinking
-			 * flag.
-			 */
-			if (tty_term_has(tty->term, TTYC_SS)) {
-				if (mode & MODE_BLINKING)
-					tty_putcode1(tty, TTYC_SS, 3);
-				else
-					tty_putcode1(tty, TTYC_SS, 4);
-			} else if (mode & MODE_BLINKING)
-				tty_putcode(tty, TTYC_CVVIS);
-			break;
-		case SCREEN_CURSOR_BAR:
-			/*
-			 * Set style to either bar blinking (5) or steady (6)
-			 * if supported, otherwise just check the blinking
-			 * flag.
-			 */
-			if (tty_term_has(tty->term, TTYC_SS)) {
-				if (mode & MODE_BLINKING)
-					tty_putcode1(tty, TTYC_SS, 5);
-				else
-					tty_putcode1(tty, TTYC_SS, 6);
-			} else if (mode & MODE_BLINKING)
-				tty_putcode(tty, TTYC_CVVIS);
-			break;
-		}
-		tty->cstyle = cstyle;
-	}
-
+	tty_update_cursor(tty, mode, changed, s);
 	if ((changed & ALL_MOUSE_MODES) &&
 	    tty_term_has(tty->term, TTYC_KMOUS)) {
 		/*
