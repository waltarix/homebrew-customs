# forked from https://github.com/sorin-ionescu/homebrew-personal/blob/c110adcb6a276b4c4e393e5d7e2b5f49af1f9ba1/sqlite.rb
class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2017/sqlite-autoconf-3170000.tar.gz"
  version "3.17.0"
  sha256 "a4e485ad3a16e054765baf6371826b5000beed07e626510896069c0bf013874c"

  bottle do
    cellar :any
    sha256 "e47cece3f8508b5ab65a16294bd43ad13cf159f91f179e9bbe967c01fd5020fb" => :sierra
    sha256 "98a4e72c05f76dc72510ee640a6ae4480e2d6e70c09b19e77e3cf931086d4998" => :el_capitan
    sha256 "e181d28776802ec7851924f80295c215f1056e1b7c8892af7ba978fdd02c454a" => :yosemite
  end

  keg_only :provided_by_osx, "macOS provides an older sqlite3."

  option "with-docs", "Install HTML documentation"
  option "without-rtree", "Disable the R*Tree index module"
  option "with-fts", "Enable the FTS3 module"
  option "with-fts5", "Enable the FTS5 module (experimental)"
  option "with-secure-delete", "Defaults secure_delete to on"
  option "with-unlock-notify", "Enable the unlock notification feature"
  option "with-icu4c", "Enable the ICU module"
  option "with-functions", "Enable more math and string functions for SQL queries"
  option "with-dbstat", "Enable the 'dbstat' virtual table"
  option "with-json1", "Enable the JSON1 extension"
  option "with-session", "Enable the session extension"
  option "with-regexp", "Enable regular expressions for SQL queries"

  depends_on "readline" => :recommended
  depends_on "icu4c" => :optional

  if build.with? "regexp"
    depends_on "pkg-config" => :build
    depends_on "pcre"
  end

  resource "functions" do
    url "https://sqlite.org/contrib/download/extension-functions.c?get=25", :using => :nounzip
    version "2010-02-06"
    sha256 "991b40fe8b2799edc215f7260b890f14a833512c9d9896aa080891330ffe4052"
  end

  resource "regexp" do
    url "https://raw.githubusercontent.com/ralight/sqlite3-pcre/c98da412b431edb4db22d3245c99e6c198d49f7a/pcre.c",
      :using => :nounzip
    version "2010-02-08"
    sha256 "3173f4fa57f311c688886479873edce0f776f9567c8a9537a4747e9b4bb2c119"
  end

  resource "docs" do
    url "https://www.sqlite.org/2017/sqlite-doc-3170000.zip"
    version "3.17.0"
    sha256 "3102d9eab879074776216357e4c9e272f63d0cda975a0819ec5baba5e0922ff6"
  end

  def install
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA=1"
    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_DISABLE_INTRINSIC" if MacOS.version <= :yosemite && ENV.compiler == :clang
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE=1" if build.with? "rtree"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1" if build.with? "fts"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS5=1" if build.with? "fts5"
    ENV.append "CPPFLAGS", "-DSQLITE_SECURE_DELETE=1" if build.with? "secure-delete"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_UNLOCK_NOTIFY=1" if build.with? "unlock-notify"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_DBSTAT_VTAB=1" if build.with? "dbstat"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1=1" if build.with? "json1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_PREUPDATE_HOOK=1 -DSQLITE_ENABLE_SESSION=1" if build.with? "session"

    if build.with? "icu4c"
      icu4c = Formula["icu4c"]
      icu4cldflags = `#{icu4c.opt_bin}/icu-config --ldflags`.tr("\n", " ")
      icu4ccppflags = `#{icu4c.opt_bin}/icu-config --cppflags`.tr("\n", " ")
      ENV.append "LDFLAGS", icu4cldflags
      ENV.append "CPPFLAGS", icu4ccppflags
      ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_ICU=1"
    end

    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--enable-dynamic-extensions",
    ]
    args << "--enable-readline" << "--disable-editline" if build.with? "readline"

    system "./configure", *args
    system "make", "install"

    if build.with? "functions"
      buildpath.install resource("functions")
      system ENV.cc, "-fno-common",
                     "-dynamiclib",
                     "extension-functions.c",
                     "-o", "libsqlitefunctions.dylib",
                     *ENV.cflags.to_s.split
      lib.install "libsqlitefunctions.dylib"
    end

    if build.with? "regexp"
      buildpath.install resource("regexp")
      ENV.append_path "PKG_CONFIG_PATH", lib + "pkgconfig"
      ENV.append "CFLAGS", `pkg-config --cflags sqlite3 libpcre`.chomp.strip
      ENV.append "LDFLAGS", `pkg-config --libs libpcre`.chomp.strip
      system ENV.cc, "-fno-common",
                     "-dynamiclib",
                     "pcre.c",
                     "-o", "libsqliteregexp.dylib",
                     *(ENV.cflags.split + ENV.ldflags.split)
      lib.install "libsqliteregexp.dylib"
    end

    doc.install resource("docs") if build.with? "docs"
  end

  def caveats
    s = ""
    if build.with?("functions") || build.with?("regexp")
      s += <<-EOS.undent
        Usage instructions for applications calling the sqlite3 API functions:

          In your application, call sqlite3_enable_load_extension(db,1) to
          allow loading external libraries.  Then load the library libsqlitefunctions
          using sqlite3_load_extension; the third argument should be 0.
          See https://sqlite.org/loadext.html.
          Select statements may now use these functions, as in
          SELECT cos(radians(inclination)) FROM satsum WHERE satnum = 25544;

        Usage instructions for the sqlite3 program:

          If the program is built so that loading extensions is permitted,
          the following will work:
           sqlite> SELECT load_extension('#{lib}/libsqlitefunctions.dylib');
           sqlite> select cos(radians(45));
           0.707106781186548
      EOS
    end
    if build.with? "readline"
      user_history = "~/.sqlite_history"
      user_history_path = File.expand_path(user_history)
      if File.exist?(user_history_path) && File.read(user_history_path).include?("\\040")
        s += <<-EOS.undent
          Homebrew has detected an existing SQLite history file that was created
          with the editline library. The current version of this formula is
          built with Readline. To back up and convert your history file so that
          it can be used with Readline, run:

            sed -i~ 's/\\\\040/ /g' #{user_history}

          before using the `sqlite` command-line tool again. Otherwise, your
          history will be lost.
        EOS
      end
    end
    s
  end

  test do
    path = testpath/"school.sql"
    path.write <<-EOS.undent
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
