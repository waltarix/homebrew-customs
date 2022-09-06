class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/index.html"
  url "https://github.com/waltarix/sqlite/releases/download/version-3.39.3-migemo/sqlite-autoconf-3390300.tar.xz"
  version "3.39.3"
  sha256 "6366f4b06b8768274428151f77bf99a96bae36fd4677912f9c80565009a56bf6"
  license "blessing"

  livecheck do
    url :homepage
    regex(%r{href=.*?releaselog/v?(\d+(?:[._]\d+)+)\.html}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first&.gsub("_", ".") }
    end
  end

  keg_only :provided_by_macos

  depends_on "pcre2"
  depends_on "readline"
  depends_on "waltarix/customs/cmigemo"
  depends_on "zlib"

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "LDFLAGS", "-flto"

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
