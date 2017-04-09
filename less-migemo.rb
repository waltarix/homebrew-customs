class LessMigemo < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "https://ftpmirror.gnu.org/less/less-481.tar.gz"
  mirror "http://www.greenwoodsoftware.com/less/less-481.tar.gz"
  sha256 "3fa38f2cf5e9e040bb44fffaa6c76a84506e379e47f5a04686ab78102090dda5"

  bottle do
    rebuild 2
    sha256 "5894668335c7ba7b3bce8d7e3db1fd899e05db8a251e9ac39d33dd0be94b6d88" => :sierra
    sha256 "b64e1e151c141f2d9bd67529e1c877542e337447c9aae4ab42409a38ee06e80d" => :el_capitan
    sha256 "1a3f2691a70564b5e4935d01fc6760a97a42b7a4cf372b6feb55f197925bf0d9" => :yosemite
  end

  devel do
    url "http://www.greenwoodsoftware.com/less/less-487.tar.gz"
    sha256 "f3dc8455cb0b2b66e0c6b816c00197a71bf6d1787078adeee0bcf2aea4b12706"
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
index 53550f0..82fc98b 100644
--- a/funcs.h
+++ b/funcs.h
@@ -209,6 +209,7 @@
 	public void opt__P ();
 	public void opt_b ();
 	public void opt_i ();
+	public void opt_migemo ();
 	public void opt__V ();
 	public void opt_D ();
 	public void opt_x ();
diff --git a/optfunc.c b/optfunc.c
index c3bb6b2..9eb9513 100644
--- a/optfunc.c
+++ b/optfunc.c
@@ -473,6 +473,26 @@ opt_i(type, s)
 }
 
 /*
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
+/*
  * Handler for the -V option.
  */
 	/*ARGSUSED*/
diff --git a/opttbl.c b/opttbl.c
index b896391..8467cec 100644
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
+		BOOL|HL_REPAINT, OPT_ON, &migemo_search, opt_migemo,
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
index 71141c7..c6458ca 100644
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
index e824acb..552ec01 100644
--- a/search.c
+++ b/search.c
@@ -1036,6 +1036,16 @@ chg_caseless()
 		clear_pattern(&search_info);
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
  * Find matching text which is currently on screen and highlight it.
