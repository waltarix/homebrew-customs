class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux.git",
    tag: "3.2-rc"

  bottle :unneeded

  if OS.linux?
    depends_on "bison" => :build
  else
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/13.0.0-r1/wcwidth9.h"
    sha256 "f00b5d73a1bb266c13bae2f9d758eaec59080ad8579cebe7d649ae125b28f9f1"
  end

  patch :DATA

  def install
    system "sh", "autogen.sh"

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
index 5ba41e9a..94603da0 100644
--- a/utf8.c
+++ b/utf8.c
@@ -26,6 +26,8 @@
 
 #include "tmux.h"
 
+#include "wcwidth9.h"
+
 struct utf8_item {
 	RB_ENTRY(utf8_item)	index_entry;
 	u_int			index;
@@ -225,10 +227,10 @@ utf8_width(struct utf8_data *ud, int *width)
 	case 0:
 		return (UTF8_ERROR);
 	}
-	*width = wcwidth(wc);
+	*width = wcwidth9(wc);
 	if (*width >= 0 && *width <= 0xff)
 		return (UTF8_DONE);
-	log_debug("UTF-8 %.*s, wcwidth() %d", (int)ud->size, ud->data, *width);
+	log_debug("UTF-8 %.*s, wcwidth9() %d", (int)ud->size, ud->data, *width);
 
 #ifndef __OpenBSD__
 	/*
