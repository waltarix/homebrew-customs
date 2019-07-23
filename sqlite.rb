class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2019/sqlite-autoconf-3290000.tar.gz"
  version "3.29.0"
  sha256 "8e7c1e2950b5b04c5944a981cb31fffbf9d2ddda939d536838ebc854481afd5b"

  bottle do
    cellar :any
    sha256 "5f2f8f36a8d13733b0374ac39bdcd32dea10315e7442b9bb9942465487cb7811" => :mojave
    sha256 "dcdc548263b6a8611d0e3532da5e216399cbd51e04277bb1ec9130fbb1125994" => :high_sierra
    sha256 "59e5e8d4abca99d7f3162bf8079be9efadebf459b6b24eaaa8d0effba8bb3fd7" => :sierra
  end

  keg_only :provided_by_macos, "macOS provides an older sqlite3"

  depends_on "pcre"
  depends_on "readline"
  depends_on "waltarix/customs/cmigemo"

  def pour_bottle?
    false
  end

  patch :DATA

  def install
    pcre = Formula["pcre"]
    migemo = Formula["cmigemo"]
    ENV.append "LDFLAGS", "-L#{pcre.lib} -lpcre"
    ENV.append "LDFLAGS", "-L#{migemo.lib} -lmigemo"
    ENV.append "CPPFLAGS", "-I#{pcre.include}"
    ENV.append "CPPFLAGS", "-I#{migemo.include}"

    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA=1"
    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1=1"

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-dynamic-extensions
      --enable-readline
      --disable-editline
      --enable-session
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    path = testpath/"school.sql"
    path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    EOS

    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
  end
end

__END__
diff --git a/sqlite3.c b/sqlite3.c
index 61bfdeb..2e82a57 100644
--- a/sqlite3.c
+++ b/sqlite3.c
@@ -155234,6 +155234,8 @@ SQLITE_PRIVATE int sqlite3StmtVtabInit(sqlite3*);
 SQLITE_PRIVATE int sqlite3Fts5Init(sqlite3*);
 #endif
 
+SQLITE_PRIVATE int sqlite3MigemoInit(sqlite3*);
+
 #ifndef SQLITE_AMALGAMATION
 /* IMPLEMENTATION-OF: R-46656-45156 The sqlite3_version[] string constant
 ** contains the text of SQLITE_VERSION macro. 
@@ -158505,6 +158507,10 @@ static int openDatabase(
   }
 #endif
 
+  if( !db->mallocFailed && rc==SQLITE_OK){
+    rc = sqlite3MigemoInit(db);
+  }
+
   /* -DSQLITE_DEFAULT_LOCKING_MODE=1 makes EXCLUSIVE the default locking
   ** mode.  -DSQLITE_DEFAULT_LOCKING_MODE=0 make NORMAL the default locking
   ** mode.  Doing nothing at all also makes NORMAL the default.
@@ -181785,6 +181791,126 @@ SQLITE_API int sqlite3_json_init(
 #endif /* !defined(SQLITE_CORE) || defined(SQLITE_ENABLE_JSON1) */
 
 /************** End of json1.c ***********************************************/
+/************** Begin file migemo.c ******************************************/
+
+#include <pcre.h>
+#include "migemo.h"
+
+SQLITE_EXTENSION_INIT1
+
+typedef struct {
+  char *s;
+  pcre *p;
+  pcre_extra *e;
+} cache_entry;
+
+#ifndef CACHE_SIZE
+#define CACHE_SIZE 16
+#endif
+
+static void func_migemo(sqlite3_context *ctx, int argc, sqlite3_value **argv){
+  const char *re, *str;
+  pcre *p;
+  pcre_extra *e;
+
+  assert(argc == 2);
+
+  re = (const char *) sqlite3_value_text(argv[0]);
+  if (!re) {
+    sqlite3_result_error(ctx, "no word", -1);
+    return;
+  }
+
+  str = (const char *) sqlite3_value_text(argv[1]);
+  if (!str) {
+    str = "";
+  }
+
+  /* simple LRU cache */
+  {
+    int i;
+    int found = 0;
+    cache_entry *cache = sqlite3_user_data(ctx);
+
+    assert(cache);
+
+    for (i = 0; i < CACHE_SIZE && cache[i].s; i++)
+      if (strcmp(re, cache[i].s) == 0) {
+        found = 1;
+        break;
+      }
+    if (found) {
+      if (i > 0) {
+        cache_entry c = cache[i];
+        memmove(cache + 1, cache, i * sizeof(cache_entry));
+        cache[0] = c;
+      }
+    }
+    else {
+      cache_entry c;
+      const char *err;
+      int pos;
+
+      migemo *m;
+      m = migemo_open("/usr/local/opt/cmigemo/share/migemo/utf-8/migemo-dict");
+      unsigned char *migemo_pattern;
+      migemo_pattern = migemo_query(m, (const unsigned char*)re);
+
+      c.p = pcre_compile((char*)migemo_pattern, 0, &err, &pos, NULL);
+
+      migemo_release(m, migemo_pattern);
+      migemo_close(m);
+
+      if (!c.p) {
+        char *e2 = sqlite3_mprintf("%s: %s (offset %d)", re, err, pos);
+        sqlite3_result_error(ctx, e2, -1);
+        sqlite3_free(e2);
+        return;
+      }
+      c.e = pcre_study(c.p, 0, &err);
+      c.s = strdup(re);
+      if (!c.s) {
+        sqlite3_result_error(ctx, "strdup: ENOMEM", -1);
+        pcre_free(c.p);
+        pcre_free(c.e);
+        return;
+      }
+      i = CACHE_SIZE - 1;
+      if (cache[i].s) {
+        free(cache[i].s);
+        assert(cache[i].p);
+        pcre_free(cache[i].p);
+        pcre_free(cache[i].e);
+      }
+      memmove(cache + 1, cache, i * sizeof(cache_entry));
+      cache[0] = c;
+    }
+    p = cache[0].p;
+    e = cache[0].e;
+  }
+
+  {
+    int rc;
+    assert(p);
+    rc = pcre_exec(p, e, str, strlen(str), 0, 0, NULL, 0);
+    sqlite3_result_int(ctx, rc >= 0);
+    return;
+  }
+}
+
+SQLITE_PRIVATE int sqlite3MigemoInit(sqlite3 *db){
+  cache_entry *cache = calloc(CACHE_SIZE, sizeof(cache_entry));
+  if (!cache) return SQLITE_ERROR;
+  sqlite3_create_function(db, "migemo", 2, SQLITE_UTF8, cache, func_migemo, NULL, NULL);
+  return SQLITE_OK;
+}
+
+SQLITE_API int sqlite3_migemo_init(sqlite3 *db, char **err, const sqlite3_api_routines *api){
+  SQLITE_EXTENSION_INIT2(api)
+  return sqlite3MigemoInit(db);
+}
+
+/************** End of migemo.c ***********************************************/
 /************** Begin file rtree.c *******************************************/
 /*
 ** 2001 September 15
