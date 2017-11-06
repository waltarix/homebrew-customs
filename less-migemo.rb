class LessMigemo < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "https://ftp.gnu.org/gnu/less/less-487.tar.gz"
  mirror "http://www.greenwoodsoftware.com/less/less-487.tar.gz"
  sha256 "f3dc8455cb0b2b66e0c6b816c00197a71bf6d1787078adeee0bcf2aea4b12706"
  revision 1

  bottle do
    sha256 "9ca07bd92196f4fbf122054b3ee394f43f14173b816a5217f05661453c13dd23" => :sierra
    sha256 "877f32f255528633a67c4ae76dfda423315473a0780f8f066b7d78af4d58bbc8" => :el_capitan
    sha256 "5be9c4ad7e6eda596a6828d1f49c70612ac02e2df6a65254e99dc1a34ecf1095" => :yosemite
  end

  def pour_bottle?
    false
  end

  patch :DATA

  depends_on "pcre"
  depends_on "ncurses"
  depends_on "waltarix/customs/cmigemo"

  def install
    migemo = Formula["cmigemo"]

    ENV.append "LDFLAGS", "-L#{migemo.lib} -lmigemo"
    ENV.append "CPPFLAGS", "-I#{migemo.include}"

    args = ["--prefix=#{prefix}"]
    args << "--with-regex=pcre"
    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end

__END__
diff --git a/funcs.h b/funcs.h
index ac63c37..c390796 100644
--- a/funcs.h
+++ b/funcs.h
@@ -210,6 +210,7 @@
 	public void opt__P ();
 	public void opt_b ();
 	public void opt_i ();
+	public void opt_migemo ();
 	public void opt__V ();
 	public void opt_D ();
 	public void opt_x ();
diff --git a/optfunc.c b/optfunc.c
index 44f8e5f..09e25a9 100644
--- a/optfunc.c
+++ b/optfunc.c
@@ -473,6 +473,26 @@ opt_i(type, s)
 	}
 }
 
+/*
+ * Handler for the -% option.
+ */
+	/*ARGSUSED*/
+	public void
+opt_migemo(type, s)
+	int type;
+	char *s;
+{
+	switch (type)
+	{
+	case TOGGLE:
+		chg_migemo_search();
+		break;
+	case QUERY:
+	case INIT:
+		break;
+	}
+}
+
 /*
  * Handler for the -V option.
  */
diff --git a/opttbl.c b/opttbl.c
index 0383837..4d05df2 100644
--- a/opttbl.c
+++ b/opttbl.c
@@ -53,6 +53,7 @@ public int quit_on_intr;	/* Quit on interrupt */
 public int follow_mode;		/* F cmd Follows file desc or file name? */
 public int oldbot;		/* Old bottom of screen behavior {{REMOVE}} */
 public int opt_use_backslash;	/* Use backslash escaping in option parsing */
+public int migemo_search;	/* Migemo search */
 #if HILITE_SEARCH
 public int hilite_search;	/* Highlight matched search patterns? */
 #endif
@@ -113,6 +114,7 @@ static struct optname quote_optname  = { "quotes",               NULL };
 static struct optname tilde_optname  = { "tilde",                NULL };
 static struct optname query_optname  = { "help",                 NULL };
 static struct optname pound_optname  = { "shift",                NULL };
+static struct optname migemo_optname = { "migemo-search",        NULL };
 static struct optname keypad_optname = { "no-keypad",            NULL };
 static struct optname oldbot_optname = { "old-bot",              NULL };
 static struct optname follow_optname = { "follow-name",          NULL };
@@ -424,6 +426,14 @@ static struct loption option[] =
 			NULL
 		}
 	},
+	{ '%', &migemo_optname,
+		BOOL|HL_REPAINT, OPT_OFF, &migemo_search, opt_migemo,
+		{
+			"Don't use migemo",
+			"Use migemo",
+			NULL
+		}
+	},
 	{ OLETTER_NONE, &keypad_optname,
 		BOOL|NO_TOGGLE, OPT_OFF, &no_keypad, NULL,
 		{
diff --git a/pattern.c b/pattern.c
index 97a73e9..7547863 100644
--- a/pattern.c
+++ b/pattern.c
@@ -13,8 +13,14 @@
 
 #include "less.h"
 #include "pattern.h"
+#include "migemo.h"
+#include <syslog.h>
+#if HAVE_LOCALE
+#include <locale.h>
+#endif
 
 extern int caseless;
+extern int migemo_search;
 
 /*
  * Compile a search pattern, for future use by match_pattern.
@@ -61,12 +67,28 @@ compile_pattern2(pattern, search_type, comp_pattern, show_error)
 	*pcomp = comp;
 #endif
 #if HAVE_PCRE
+	char **ptr_pattern = &pattern;
+	migemo *m = NULL;
+	char *migemo_pattern;
+
+	if (migemo_search) {
+#if HAVE_LOCALE
+		setlocale(LC_ALL, "C");
+#endif
+		m = migemo_open("/usr/local/opt/cmigemo/share/migemo/utf-8/migemo-dict");
+#if HAVE_LOCALE
+		setlocale(LC_ALL, "");
+#endif
+		migemo_pattern = (char*)migemo_query(m, (const unsigned char*)pattern);
+		ptr_pattern = &migemo_pattern;
+	}
+
 	pcre *comp;
 	pcre **pcomp = (pcre **) comp_pattern;
 	constant char *errstring;
 	int erroffset;
 	PARG parg;
-	comp = pcre_compile(pattern, 0,
+	comp = pcre_compile(*ptr_pattern, 0,
 			&errstring, &erroffset, NULL);
 	if (comp == NULL)
 	{
@@ -76,6 +98,11 @@ compile_pattern2(pattern, search_type, comp_pattern, show_error)
 		return (-1);
 	}
 	*pcomp = comp;
+
+	if (m != NULL) {
+		migemo_release(m, (unsigned char*)migemo_pattern);
+		migemo_close(m);
+	}
 #endif
 #if HAVE_RE_COMP
 	PARG parg;
diff --git a/search.c b/search.c
index 750b74a..dac68e8 100644
--- a/search.c
+++ b/search.c
@@ -358,6 +358,16 @@ undo_search()
 #endif
 }
 
+/*
+ * Toggle usage state of migemo.
+ * Updates the internal search state to reflect a change in the -% flag.
+ */
+	public void
+chg_migemo_search()
+{
+	clear_pattern(&search_info);
+}
+
 #if HILITE_SEARCH
 /*
  * Clear the hilite list.
