class Libpq < Formula
  desc "Postgres C API library"
  homepage "https://www.postgresql.org/docs/15/libpq.html"
  url "https://ftp.postgresql.org/pub/source/v15.3/postgresql-15.3.tar.bz2"
  sha256 "ffc7d4891f00ffbf5c3f4eab7fbbced8460b8c0ee63c5a5167133b9e6599d932"
  license "PostgreSQL"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  keg_only "conflicts with postgres formula"

  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  depends_on "krb5"

  depends_on "openssl@3"
  depends_on "readline"
  depends_on "zlib"

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.0.0-r5/wcwidth9.h"
    sha256 "3272d3b4e3b2068f52093f99609c2ebbe35f60e879daa9ab96481c76f7ce5250"
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
