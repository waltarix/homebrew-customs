require 'formula'

class Sl < Formula
  homepage 'https://packages.debian.org/source/stable/sl'
  url 'https://mirrors.kernel.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz'
  mirror 'http://http.debian.net/debian/pool/main/s/sl/sl_3.03.orig.tar.gz'
  sha256 "5986d9d47ea5e812d0cbd54a0fc20f127a02d13b45469bb51ec63856a5a6d3aa"

  fails_with :clang do
    build 318
  end

  patch :p1 do
    url "http://distfiles.gentoo.org/distfiles/sl5-1.patch"
    sha256 "4943b6f000f518ed08755b36d9b753291989c4867e55d74bc4cc4502f6e9422f"
  end

  patch :DATA

  def install
    system "make -e"
    bin.install "sl"
    man1.install "sl.1"
  end
end

__END__
diff --git a/Makefile b/Makefile
index 4d4aefa..1b98710 100644
--- a/Makefile
+++ b/Makefile
@@ -11,7 +11,7 @@ CC = gcc
 
 # For Linux 2.0.x
 LDFLAGS = -lncurses -ltermcap
-CFLAGS = -Wall -O2 -DLINUX20 $(DEBUGOPTS)
+CFLAGS = -Wall -O2 $(DEBUGOPTS)
 
 # For Solaris
 #LDFLAGS = -lcurses -ltermcap
