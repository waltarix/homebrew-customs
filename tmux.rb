class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz"
  sha256 "9ded7d100313f6bc5a87404a4048b3745d61f2332f99ec1400a7c4ed9485d452"

  bottle do
    sha256 "673822df46dec9d718fc2b4300fd2b95a261093cf3a256d71286d8fa79c6e4ef" => :high_sierra
    sha256 "79e893ee81d2cd2af20f08aa4ba52297ad24bc9fb2c4d729b61a12f83aa2eec8" => :sierra
    sha256 "a4f05bb40d0c699fac50f053500710d486aaf1ca0cb4fc96e75cb2d4b8461931" => :el_capitan
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
  depends_on "utf8proc" => :optional
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
  end

  patch :DATA

  resource "wcwidth9.h" do
    url "https://gist.githubusercontent.com/waltarix/7a36cc9f234a4a2958a24927696cf87c/raw/d4a38bc596f798b0344d06e9c831677f194d8148/wcwidth9.h"
    sha256 "50b5f30757ed9e1f9bece87dec4d70e32eee780f42b558242e4e76b1f9b334c8"
  end

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
