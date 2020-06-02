class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2020/sqlite-autoconf-3320100.tar.gz"
  version "3.32.1"
  sha256 "486748abfb16abd8af664e3a5f03b228e5f124682b0c942e157644bf6fff7d10"
  revision 1

  bottle :unneeded

  keg_only :provided_by_macos

  depends_on "pcre2"
  depends_on "readline"
  depends_on "waltarix/customs/cmigemo"

  patch :DATA

  def install
    ENV.append "LDFLAGS", "-lmigemo"
    ENV.append "LDFLAGS", "-lpcre2-8"

    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA=1"
    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_MIGEMO=1"

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
index 19c8768..211a6dc 100644
--- a/sqlite3.c
+++ b/sqlite3.c
@@ -293,6 +293,9 @@ static const char * const sqlite3azCompileOpt[] = {
 #if SQLITE_ENABLE_MEMSYS5
   "ENABLE_MEMSYS5",
 #endif
+#if SQLITE_ENABLE_MIGEMO
+  "ENABLE_MIGEMO",
+#endif
 #if SQLITE_ENABLE_MULTIPLEX
   "ENABLE_MULTIPLEX",
 #endif
@@ -1164,7 +1167,7 @@ extern "C" {
 */
 #define SQLITE_VERSION        "3.32.1"
 #define SQLITE_VERSION_NUMBER 3032001
-#define SQLITE_SOURCE_ID      "2020-05-25 16:19:56 0c1fcf4711a2e66c813aed38cf41cd3e2123ee8eb6db98118086764c4ba83350"
+#define SQLITE_SOURCE_ID      "2020-05-25 16:19:56 0c1fcf4711a2e66c813aed38cf41cd3e2123ee8eb6db98118086764c4ba8alt1"
 
 /*
 ** CAPI3REF: Run-Time Library Version Numbers
@@ -160220,6 +160223,9 @@ SQLITE_PRIVATE int sqlite3Json1Init(sqlite3*);
 #ifdef SQLITE_ENABLE_STMTVTAB
 SQLITE_PRIVATE int sqlite3StmtVtabInit(sqlite3*);
 #endif
+#ifdef SQLITE_ENABLE_MIGEMO
+SQLITE_PRIVATE int sqlite3MigemoInit(sqlite3*);
+#endif
 
 /*
 ** An array of pointers to extension initializer functions for
@@ -160260,6 +160266,9 @@ static int (*const sqlite3BuiltinExtensions[])(sqlite3*) = {
 #ifdef SQLITE_ENABLE_BYTECODE_VTAB
   sqlite3VdbeBytecodeVtabInit,
 #endif
+#ifdef SQLITE_ENABLE_MIGEMO
+  sqlite3MigemoInit,
+#endif
 };
 
 #ifndef SQLITE_AMALGAMATION
@@ -187182,6 +187191,165 @@ SQLITE_API int sqlite3_json_init(
 #endif /* !defined(SQLITE_CORE) || defined(SQLITE_ENABLE_JSON1) */
 
 /************** End of json1.c ***********************************************/
+/************** Begin file migemo.c ******************************************/
+#if !defined(SQLITE_CORE) || defined(SQLITE_ENABLE_MIGEMO)
+
+/* #include "sqlite3ext.h" */
+SQLITE_EXTENSION_INIT1
+
+/* #include <assert.h> */
+/* #include <string.h> */
+/* #include <stdio.h> */
+
+#define PCRE2_CODE_UNIT_WIDTH 8
+#include <pcre2.h>
+#include <migemo.h>
+
+#ifndef MIGEMO_CACHE_SIZE
+#define MIGEMO_CACHE_SIZE 16
+#endif
+
+typedef struct {
+  char *pattern;
+  pcre2_code *regexp;
+} MigemoCacheEntry;
+
+typedef struct {
+  migemo *pmigemo;
+  MigemoCacheEntry *entries;
+} MigemoCache;
+
+static void migemoFunc(sqlite3_context *ctx, int argc, sqlite3_value **argv){
+  const char *zPattern, *zSubject;
+  char *errmsg;
+  pcre2_code *regexp;
+  int jitRc;
+
+  assert(argc == 2);
+
+  zPattern = (const char*)sqlite3_value_text(argv[0]);
+  if( !zPattern ){
+    sqlite3_result_error(ctx, "no word", -1);
+    return;
+  }
+
+  zSubject = (const char*)sqlite3_value_text(argv[1]);
+  if( !zSubject ) zSubject = "";
+
+  /* simple LRU cache */
+  {
+    int i;
+    int found = 0;
+    MigemoCache *migemoCache = sqlite3_user_data(ctx);
+    MigemoCacheEntry *entries = migemoCache->entries;
+    assert(entries);
+
+    for (i = 0; i < MIGEMO_CACHE_SIZE && entries[i].pattern; i++)
+      if( strcmp(zPattern, entries[i].pattern)==0 ){
+        found = 1;
+        break;
+      }
+    if( found ){
+      if( i > 0 ){
+        MigemoCacheEntry entry = entries[i];
+        memmove(entries + 1, entries, i * sizeof(MigemoCacheEntry));
+        entries[0] = entry;
+      }
+    }else{
+      unsigned char *migemoPattern;
+      MigemoCacheEntry entry;
+      int errorCode;
+      PCRE2_SIZE errorOffset;
+      PCRE2_UCHAR errorBuffer[256];
+
+      migemoPattern = migemo_query(migemoCache->pmigemo, (const unsigned char*)zPattern);
+      entry.regexp = pcre2_compile((PCRE2_SPTR)migemoPattern, strlen((const char*)migemoPattern),
+          PCRE2_UTF, &errorCode, &errorOffset, NULL);
+      migemo_release(migemoCache->pmigemo, migemoPattern);
+
+      if( !entry.regexp ){
+        pcre2_get_error_message(errorCode, errorBuffer, sizeof(errorBuffer));
+        sqlite3_result_error(ctx, (const char*)errorBuffer, -1);
+        return;
+      }
+
+      jitRc = pcre2_jit_compile(entry.regexp, PCRE2_JIT_COMPLETE);
+      if( jitRc ){
+        errmsg = sqlite3_mprintf("Couldn't JIT: %d", jitRc);
+        sqlite3_result_error(ctx, errmsg, -1);
+        sqlite3_free(errmsg);
+        pcre2_code_free(entry.regexp);
+        return;
+      }
+
+      entry.pattern = strdup(zPattern);
+      if( !entry.pattern ){
+        sqlite3_result_error(ctx, "strdup: ENOMEM", -1);
+        pcre2_code_free(entry.regexp);
+        return;
+      }
+
+      i = MIGEMO_CACHE_SIZE - 1;
+      if( entries[i].pattern ){
+        free(entries[i].pattern);
+        assert(entries[i].regexp);
+        pcre2_code_free(entries[i].regexp);
+      }
+      memmove(entries + 1, entries, i * sizeof(MigemoCacheEntry));
+      entries[0] = entry;
+    }
+    regexp = entries[0].regexp;
+  }
+
+  {
+    assert(regexp);
+
+    pcre2_match_data *matchData = pcre2_match_data_create_from_pattern(regexp, NULL);
+    jitRc = pcre2_jit_match(regexp, (PCRE2_SPTR)zSubject, strlen(zSubject), 0, 0, matchData, NULL);
+    pcre2_match_data_free(matchData);
+
+    sqlite3_result_int(ctx, jitRc >= 0);
+  }
+}
+
+static void migemoFreeCallback(void *p){
+  MigemoCache *migemoCache = (MigemoCache*)p;
+  migemo_close(migemoCache->pmigemo);
+  free(migemoCache->entries);
+  sqlite3_free(p);
+}
+
+SQLITE_PRIVATE int sqlite3MigemoInit(sqlite3 *db){
+  MigemoCache *migemoCache = sqlite3_malloc(sizeof(MigemoCache));
+  if( !migemoCache ) return SQLITE_NOMEM;
+  migemoCache->pmigemo = migemo_open("/usr/local/opt/cmigemo/share/migemo/utf-8/migemo-dict");
+
+  migemoCache->entries = calloc(MIGEMO_CACHE_SIZE, sizeof(MigemoCacheEntry));
+  if( !migemoCache->entries ) return SQLITE_NOMEM;
+
+  return sqlite3_create_function_v2(db, "migemo", 2, SQLITE_UTF8,
+      migemoCache, migemoFunc, NULL, NULL, migemoFreeCallback
+  );
+}
+
+#ifndef SQLITE_CORE
+#ifdef _WIN32
+__declspec(dllexport)
+#endif
+SQLITE_API int sqlite3_migemo_init(
+  sqlite3 *db,
+  char **pzErrMsg,
+  const sqlite3_api_routines *pApi
+){
+  SQLITE_EXTENSION_INIT2(pApi)
+  (void)pzErrMsg; /* Unused parameter */
+  return sqlite3MigemoInit(db);
+}
+#endif
+
+#endif /* !defined(SQLITE_CORE) || defined(SQLITE_ENABLE_MIGEMO) */
+
+/************** End of migemo.c **********************************************/
 /************** Begin file rtree.c *******************************************/
 /*
 ** 2001 September 15
@@ -229605,7 +229773,7 @@ SQLITE_API int sqlite3_stmt_init(
 #endif /* !defined(SQLITE_CORE) || defined(SQLITE_ENABLE_STMTVTAB) */
 
 /************** End of stmt.c ************************************************/
-#if __LINE__!=229608
+#if __LINE__!=229776
 #undef SQLITE_SOURCE_ID
 #define SQLITE_SOURCE_ID      "2020-05-25 16:19:56 0c1fcf4711a2e66c813aed38cf41cd3e2123ee8eb6db98118086764c4ba8alt2"
 #endif
