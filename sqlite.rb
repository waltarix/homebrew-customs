class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://github.com/waltarix/sqlite/releases/download/version-3.34.1-migemo/sqlite-autoconf-3340100.tar.gz"
  version "3.34.1"
  sha256 "72e67918b1f42dd721e1bf46b63d2bfee5db2bafa5109c8030731db37ab30a8a"
  license "blessing"

  livecheck do
    url "https://sqlite.org/news.html"
    regex(%r{v?(\d+(?:\.\d+)+)</h3>}i)
  end

  bottle :unneeded

  keg_only :provided_by_macos

  depends_on "pcre2"
  depends_on "readline"
  depends_on "waltarix/customs/cmigemo"
  depends_on "zlib"

  def install
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
      --enable-migemo
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

    path = testpath/"school-migemo.sql"
    path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('ボブ', 14);
      insert into students (name, age) values ('スー', 12);
      insert into students (name, age) values ('ティム', 13);
      select name from students where MIGEMO('bob', name);
    EOS
    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[ボブ], names
  end
end
