class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/2.9a/tmux-2.9a.tar.gz"
  sha256 "839d167a4517a6bffa6b6074e89a9a8630547b2dea2086f1fad15af12ab23b25"

  bottle do
    cellar :any
    sha256 "39e422362b56750f805e9725c498fd5653987a26e1b892d5f0d40820616be69d" => :mojave
    sha256 "5c7148b6beb43995a0f53504f9a3f0500420e5ad11e17f34ce60401f42b833df" => :high_sierra
    sha256 "b59dc70fea0e69398d757e5212d5d21642ee552518af5870f789312465c88500" => :sierra
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
