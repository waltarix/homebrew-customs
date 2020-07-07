class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2020/sqlite-autoconf-3320300.tar.gz"
  version "3.32.3"
  sha256 "a31507123c1c2e3a210afec19525fd7b5bb1e19a6a34ae5b998fbd7302568b66"

  bottle :unneeded

  keg_only :provided_by_macos

  depends_on "pcre2"
  depends_on "readline"
  depends_on "waltarix/customs/cmigemo"

  uses_from_macos "zlib"

  resource "sqlite3.c" do
    url "https://github.com/waltarix/sqlite/releases/download/version-3.32.3-migemo-r1/sqlite3.c.xz"
    sha256 "5b688ad0aed33bdcae6796f401f058762532d73a924bb86422c769ddc65e0f3f"
  end

  def install
    resource("sqlite3.c").stage buildpath

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
