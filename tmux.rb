class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/2.8/tmux-2.8.tar.gz"
  sha256 "7f6bf335634fafecff878d78de389562ea7f73a7367f268b66d37ea13617a2ba"

  bottle do
    sha256 "1853b704405374f88dcb00ef4c82c18efbcbac2ce855de681bd7017c3b5e6b36" => :mojave
    sha256 "b50d0ac39ae8219d84b9fba7ae5f0422143d8a7a9575b9193d7604dc1b3a85f0" => :high_sierra
    sha256 "d4b259196136dfb9fe4cf68a348d68edc58ac2b6d0954fe60c6694b053826cd3" => :sierra
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
  depends_on "utf8proc" => :optional

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

    args << "--enable-utf8proc" if build.with?("utf8proc")

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
index a91da36..212d1a2 100644
--- a/utf8.c
+++ b/utf8.c
@@ -25,6 +25,8 @@
 
 #include "tmux.h"
 
+#include "wcwidth9.h"
+
 static int	utf8_width(wchar_t);
 
 /* Set a single character. */
@@ -112,7 +114,7 @@ utf8_width(wchar_t wc)
 #ifdef HAVE_UTF8PROC
 	width = utf8proc_wcwidth(wc);
 #else
-	width = wcwidth(wc);
+	width = wcwidth9(wc);
 #endif
 	if (width < 0 || width > 0xff) {
 		log_debug("Unicode %04lx, wcwidth() %d", (long)wc, width);
