class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/waltarix/tmux/releases/download/3.2-rc4-custom/tmux-3.2-rc4.tar.xz"
  sha256 "0f6b494f638cf2866051f777fbc094d59251eb726ed72dd6d8f1f05752731118"
  license "ISC"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  bottle :unneeded

  if OS.linux?
    depends_on "bison" => :build
    depends_on "jemalloc"
  else
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/f5d53239f7658f8e8fbaf02535cc369009c436d6/completions/tmux"
    sha256 "b5f7bbd78f9790026bbff16fc6e3fe4070d067f58f943e156bd1a8c3c99f6a6f"
  end

  patch :DATA

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    on_linux do
      ENV.append "LIBS", "-ljemalloc"
    end

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
diff --git a/cmd-display-menu.c b/cmd-display-menu.c
index 5a5aabcd..6886d443 100644
--- a/cmd-display-menu.c
+++ b/cmd-display-menu.c
@@ -50,7 +50,7 @@ const struct cmd_entry cmd_display_popup_entry = {
 	.name = "display-popup",
 	.alias = "popup",
 
-	.args = { "Cc:d:Eh:t:w:x:y:", 0, -1 },
+	.args = { "Cc:d:Eh:t:w:x:y:KR", 0, -1 },
 	.usage = "[-CE] [-c target-client] [-d start-directory] [-h height] "
 	         CMD_TARGET_PANE_USAGE " [-w width] "
 	         "[-x position] [-y position] [command]",
