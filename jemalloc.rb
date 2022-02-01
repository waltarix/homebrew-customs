class Jemalloc < Formula
  desc "Implementation of malloc emphasizing fragmentation avoidance"
  homepage "http://jemalloc.net/"
  url "https://github.com/jemalloc/jemalloc/archive/20f9802e4f25922884448d9581c66d76cc905c0c.tar.gz"
  version "5.3-rc"
  sha256 "9ce95313bdd50629467c29069a6fedb50804ec4b56053250ac0c0d53551151da"
  license "BSD-2-Clause"

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
