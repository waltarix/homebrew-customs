class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.0a/tmux-3.0a.tar.gz"
  sha256 "4ad1df28b4afa969e59c08061b45082fdc49ff512f30fc8e43217d7b0e5f8db9"

  bottle do
    cellar :any
    sha256 "3d29caf7e2b87c9f1af575b4ec10af3e29c5de6979a8bd884153d9e8e1b69f20" => :catalina
    sha256 "6cfd3987dcda2901a3ed423138db7782ea88a993e1409c4ebb9d647b1c007e8a" => :mojave
    sha256 "c7c42853ca6a3a5ad6ab6544defee14e450643f5ace274b9cf00d348e8525993" => :high_sierra
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def pour_bottle?
    false
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
  end

  resource "wcwidth9.h" do
    url "https://gist.githubusercontent.com/waltarix/7a36cc9f234a4a2958a24927696cf87c/raw/d4a38bc596f798b0344d06e9c831677f194d8148/wcwidth9.h"
    sha256 "50b5f30757ed9e1f9bece87dec4d70e32eee780f42b558242e4e76b1f9b334c8"
  end

  patch :DATA

  def install
    system "sh", "autogen.sh" if build.head?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    buildpath.install resource("wcwidth9.h")

    ncurses = Formula["ncurses"]
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats; <<~EOS
    Example configuration has been installed to:
      #{opt_pkgshare}
  EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end

__END__
diff --git a/utf8.c b/utf8.c
index 224aa482..e5298de2 100644
--- a/utf8.c
+++ b/utf8.c
@@ -26,6 +26,8 @@
 
 #include "tmux.h"
 
+#include "wcwidth9.h"
+
 static int	utf8_width(wchar_t);
 
 /* Set a single character. */
@@ -113,7 +115,7 @@ utf8_width(wchar_t wc)
 #ifdef HAVE_UTF8PROC
 	width = utf8proc_wcwidth(wc);
 #else
-	width = wcwidth(wc);
+	width = wcwidth9(wc);
 #endif
 	if (width < 0 || width > 0xff) {
 		log_debug("Unicode %04lx, wcwidth() %d", (long)wc, width);
