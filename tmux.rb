class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/3.1b/tmux-3.1b.tar.gz"
  sha256 "d93f351d50af05a75fe6681085670c786d9504a5da2608e481c47cf5e1486db9"

  bottle do
    cellar :any
    sha256 "f26bd0c3f5696350dcaf229d0fadaf6ab677c0ebbb550fc499ca0a37da59ab55" => :catalina
    sha256 "e9995ca765078be9cfdef4f1b6a628bcded0e96e36649e084a7f5480d165547a" => :mojave
    sha256 "7a04ece8143c0647be18bb14c160a984a5a9f855fa2ee888d21fc19374790ee5" => :high_sierra
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
    url "https://gist.githubusercontent.com/waltarix/7a36cc9f234a4a2958a24927696cf87c/raw/53c3983f52469c4808714903d3a0597af930432e/wcwidth9.h"
    sha256 "d886a1e0e95d9a203ea61c6ecba690ac9a3f82d943c5668d646a6200cf1d1a4f"
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

  def caveats
    <<~EOS
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
index b4e448f7..e0c81d9b 100644
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
