require 'formula'

class Sl < Formula
  homepage 'http://packages.debian.org/source/stable/sl'
  url 'http://mirrors.kernel.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz'
  mirror 'http://ftp.us.debian.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz'
  sha1 'd0a8e52ef649cd3bbf02c099e9991dc7cb9b60c3'

  fails_with :clang do
    build 318
  end

  def patches
    [
      'http://www.izumix.org.uk/sl/sl5-1.patch',
      DATA
    ]
  end

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
