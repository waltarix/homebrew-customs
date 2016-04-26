class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"

  stable do
    url "https://github.com/tmux/tmux/releases/download/2.2/tmux-2.2.tar.gz"
    sha256 "bc28541b64f99929fe8e3ae7a02291263f3c97730781201824c0f05d7c8e19e4"
  end

  def pour_bottle?
    false
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "homebrew/dupes/ncurses"
  depends_on "waltarix/customs/wcwidth-cjk"

  stable do
    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/e2c3b43503507c6002d6cb169ddd098b755a427e/tmux-do-not-combine-utf8.patch"
      sha256 "aa05d74c7078bc622cfba8e16141a01f0c807d5a2708f76d14e40b33ee0afa6e"
    end

    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/e2c3b43503507c6002d6cb169ddd098b755a427e/tmux-pane-border-ascii.patch"
      sha256 "2d1cde911ae7d29a30eab4ab44b9371283a3418e2706b8c9b13cbe3ae20a473c"
    end
  end

  resource "completion" do
    url "https://raw.githubusercontent.com/przepompownia/tmux-bash-completion/v0.0.1/completions/tmux"
    sha256 "a0905c595fec7f0258fba5466315d42d67eca3bd2d3b12f4af8936d7f168b6c6"
  end

  def install
    system "sh", "autogen.sh" if build.head?

    ncurses = Formula["ncurses"]
    wcwidth = Formula["wcwidth-cjk"]

    ENV.append "LDFLAGS", "-lresolv"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"
    ENV.append "LDFLAGS", "-L#{wcwidth.lib} -lwcwidth-cjk"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"

    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats; <<-EOS.undent
    Example configuration has been installed to:
      #{opt_pkgshare}
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
