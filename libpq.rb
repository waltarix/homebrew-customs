class Libpq < Formula
  desc "Postgres C API library"
  homepage "https://www.postgresql.org/docs/14/libpq.html"
  url "https://ftp.postgresql.org/pub/source/v14.5/postgresql-14.5.tar.bz2"
  sha256 "d4f72cb5fb857c9a9f75ec8cf091a1771272802f2178f0b2e65b7b6ff64f4a30"
  license "PostgreSQL"
  revision 1

  livecheck do
    formula "postgresql"
  end

  keg_only "conflicts with postgres formula"

  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  depends_on "krb5"

  depends_on "openssl@1.1"

  on_linux do
    depends_on "readline"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.0.0/wcwidth9.h"
    sha256 "a18bd4ddc6a27e9f7a9c9ba273bf3a120846f31fe32f00972aa7987d21e3154d"
  end

  def install
    resource("wcwidth9.h").stage(buildpath/"src/common")
    inreplace "src/common/wchar.c" do |s|
      s.gsub! %r@(?<=^#include "mb/pg_wchar\.h")@, %@\n#include "wcwidth9.h"@
      s.gsub! /(?<=return )ucs_wcwidth/, "wcwidth9"
    end

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-gssapi",
                          "--with-openssl",
                          "--libdir=#{opt_lib}",
                          "--includedir=#{opt_include}"
    dirs = %W[
      libdir=#{lib}
      includedir=#{include}
      pkgincludedir=#{include}/postgresql
      includedir_server=#{include}/postgresql/server
      includedir_internal=#{include}/postgresql/internal
    ]
    system "make"
    system "make", "-C", "src/bin", "install", *dirs
    system "make", "-C", "src/include", "install", *dirs
    system "make", "-C", "src/interfaces", "install", *dirs
    system "make", "-C", "src/common", "install", *dirs
    system "make", "-C", "src/port", "install", *dirs
    system "make", "-C", "doc", "install", *dirs
  end

  test do
    (testpath/"libpq.c").write <<~EOS
      #include <stdlib.h>
      #include <stdio.h>
      #include <libpq-fe.h>

      int main()
      {
          const char *conninfo;
          PGconn     *conn;

          conninfo = "dbname = postgres";

          conn = PQconnectdb(conninfo);

          if (PQstatus(conn) != CONNECTION_OK) // This should always fail
          {
              printf("Connection to database attempted and failed");
              PQfinish(conn);
              exit(0);
          }

          return 0;
        }
    EOS
    system ENV.cc, "libpq.c", "-L#{lib}", "-I#{include}", "-lpq", "-o", "libpqtest"
    assert_equal "Connection to database attempted and failed", shell_output("./libpqtest")
  end
end
