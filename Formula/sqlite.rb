class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/index.html"
  url "https://github.com/waltarix/sqlite/releases/download/version-3.49.1-custom/sqlite-autoconf-3490100.tar.xz"
  version "3.49.1"
  sha256 "34497aa645dac8c571c5212ec0bbbe69299101243f06cfb7d7ddd8eae4cc7e47"
  license "blessing"

  livecheck do
    url :homepage
    regex(%r{href=.*?releaselog/v?(\d+(?:[._]\d+)+)\.html}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match&.first&.tr("_", ".") }
    end
  end

  keg_only :provided_by_macos

  depends_on "pcre2"
  depends_on "readline"
  depends_on "waltarix/customs/cmigemo"
  depends_on "zlib"

  # add macos linker patch, upstream discussion, https://sqlite.org/forum/forumpost/a179331cbb
  # patch do
  #   url "https://raw.githubusercontent.com/Homebrew/formula-patches/c797b2d7779960ba443c498c04c02e8a47626f33/sqlite/3.49.0-macos-linker.patch"
  #   sha256 "d284149cc327be3e5e9a0a7150ce584f5da584e44645ad036b6d2cd143e3e638"
  # end

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append_to_cflags "-flto"
    ENV.append_to_cflags "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", %w[
      -DSQLITE_ENABLE_API_ARMOR=1
      -DSQLITE_ENABLE_COLUMN_METADATA=1
      -DSQLITE_ENABLE_DBSTAT_VTAB=1
      -DSQLITE_ENABLE_FTS3=1
      -DSQLITE_ENABLE_FTS3_PARENTHESIS=1
      -DSQLITE_ENABLE_FTS5=1
      -DSQLITE_ENABLE_JSON1=1
      -DSQLITE_ENABLE_MEMORY_MANAGEMENT=1
      -DSQLITE_ENABLE_RTREE=1
      -DSQLITE_ENABLE_STAT4=1
      -DSQLITE_ENABLE_UNLOCK_NOTIFY=1
      -DSQLITE_MAX_VARIABLE_NUMBER=250000
      -DSQLITE_USE_URI=1
    ].join(" ")

    args = [
      "--enable-readline",
      "--disable-editline",
      "--enable-session",
      "--with-readline-cflags=-I#{Formula["readline"].opt_include}",
      "--with-readline-ldflags=-L#{Formula["readline"].opt_lib} -lreadline",
      "--migemo",
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"

    # Avoid rebuilds of dependants that hardcode this path.
    inreplace lib/"pkgconfig/sqlite3.pc", prefix, opt_prefix
  end

  test do
    path = testpath/"school.sql"
    path.write <<~SQL
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    SQL
    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names

    path = testpath/"school-migemo.sql"
    path.write <<~SQL
      create table students (name text, age integer);
      insert into students (name, age) values ('ボブ', 14);
      insert into students (name, age) values ('スー', 12);
      insert into students (name, age) values ('ティム', 13);
      select name from students where MIGEMO('bob', name);
    SQL
    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[ボブ], names
  end
end
