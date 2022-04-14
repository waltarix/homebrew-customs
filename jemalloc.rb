class Jemalloc < Formula
  desc "Implementation of malloc emphasizing fragmentation avoidance"
  homepage "http://jemalloc.net/"
  url "https://github.com/jemalloc/jemalloc/archive/ed5fc14b28ca62a6ba57b65adf557e1ef09037f0.tar.gz"
  version "5.3-rc"
  sha256 "81f7ce57f07dd84bf0390fd2a054e7f0dd9c85f891779f46b530404336599378"
  license "BSD-2-Clause"
  revision 1

  depends_on "docbook-xsl" => :build

  on_macos do
    depends_on "autoconf" => :build
  end

  on_linux do
    depends_on "libxslt" => :build
  end

  def install
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-jemalloc-prefix=
      --with-xslroot=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
    ]

    system "./autogen.sh", *args
    system "make", "dist"

    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdlib.h>
      #include <jemalloc/jemalloc.h>

      int main(void) {

        for (size_t i = 0; i < 1000; i++) {
            // Leak some memory
            malloc(i * 100);
        }

        // Dump allocator statistics to stderr
        malloc_stats_print(NULL, NULL, NULL);
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ljemalloc", "-o", "test"
    system "./test"
  end
end
