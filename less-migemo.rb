class LessMigemo < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "http://www.greenwoodsoftware.com/less/less-551.tar.gz"
  sha256 "ff165275859381a63f19135a8f1f6c5a194d53ec3187f94121ecd8ef0795fe3d"

  bottle do
    cellar :any
    sha256 "a76b3f1fb43e1e0ab566a70eca5430afa744d6d87430b55e9a5b98160834c8b9" => :catalina
    sha256 "2ee3f16d15855ab88ad87067085c0f2dd58c90c5b91ae51499ae0548a24693b2" => :mojave
    sha256 "46cd5ba33b6a1d00cfa3993712ea617bce5b6c9908b016a72413f370eda714be" => :high_sierra
  end

  def pour_bottle?
    false
  end

  depends_on "ncurses"
  depends_on "pcre"
  depends_on "waltarix/customs/cmigemo"

  patch :DATA

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
index 9686df1..5bae752 100644
--- a/funcs.h
+++ b/funcs.h
@@ -229,6 +229,7 @@ public void opt_p LESSPARAMS ((int type, char *s));
 public void opt__P LESSPARAMS ((int type, char *s));
 public void opt_b LESSPARAMS ((int type, char *s));
 public void opt_i LESSPARAMS ((int type, char *s));
+public void opt_migemo LESSPARAMS ((int type, char *s));
 public void opt__V LESSPARAMS ((int type, char *s));
 public void opt_D LESSPARAMS ((int type, char *s));
 public void opt_x LESSPARAMS ((int type, char *s));
diff --git a/optfunc.c b/optfunc.c
index 7fe947e..8bf90bb 100644
--- a/optfunc.c
+++ b/optfunc.c
@@ -488,6 +488,26 @@ opt_i(type, s)
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
index 967761c..6bb02d3 100644
--- a/opttbl.c
+++ b/opttbl.c
@@ -59,6 +59,7 @@ public int no_hist_dups;	/* Remove dups from history list */
 public int mousecap;		/* Allow mouse for scrolling */
 public int wheel_lines;		/* Number of lines to scroll on mouse wheel scroll */
 public int perma_marks;		/* Save marks in history file */
+public int migemo_search;	/* Migemo search */
 #if HILITE_SEARCH
 public int hilite_search;	/* Highlight matched search patterns? */
 #endif
@@ -119,6 +120,7 @@ static struct optname quote_optname  = { "quotes",               NULL };
 static struct optname tilde_optname  = { "tilde",                NULL };
 static struct optname query_optname  = { "help",                 NULL };
 static struct optname pound_optname  = { "shift",                NULL };
+static struct optname migemo_optname = { "migemo-search",        NULL };
 static struct optname keypad_optname = { "no-keypad",            NULL };
 static struct optname oldbot_optname = { "old-bot",              NULL };
 static struct optname follow_optname = { "follow-name",          NULL };
@@ -435,6 +437,14 @@ static struct loption option[] =
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
index da27dc6..a08ba47 100644
--- a/pattern.c
+++ b/pattern.c
@@ -12,9 +12,15 @@
  */
 
 #include "less.h"
+#include "migemo.h"
+#include <syslog.h>
+#if HAVE_LOCALE
+#include <locale.h>
+#endif
 
 extern int caseless;
 extern int utf_mode;
+extern int migemo_search;
 
 /*
  * Compile a search pattern, for future use by match_pattern.
@@ -64,10 +70,24 @@ compile_pattern2(pattern, search_type, comp_pattern, show_error)
 	*comp_pattern = comp;
 #endif
 #if HAVE_PCRE
+	char **ptr_pattern = &pattern;
+	migemo *m = NULL;
+	char *migemo_pattern;
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
+   }
 	constant char *errstring;
 	int erroffset;
 	PARG parg;
-	pcre *comp = pcre_compile(pattern,
+	pcre *comp = pcre_compile(*ptr_pattern,
 			(utf_mode) ? PCRE_UTF8 | PCRE_NO_UTF8_CHECK : 0,
 			&errstring, &erroffset, NULL);
 	if (comp == NULL)
@@ -78,6 +98,10 @@ compile_pattern2(pattern, search_type, comp_pattern, show_error)
 		return (-1);
 	}
 	*comp_pattern = comp;
+	if (m != NULL) {
+		migemo_release(m, (unsigned char*)migemo_pattern);
+		migemo_close(m);
+	}
 #endif
 #if HAVE_PCRE2
 	int errcode;
diff --git a/search.c b/search.c
index e1d0073..0d215e2 100644
--- a/search.c
+++ b/search.c
@@ -362,6 +362,16 @@ undo_search(VOID_PARAM)
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
