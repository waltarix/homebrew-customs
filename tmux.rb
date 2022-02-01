class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/waltarix/tmux/releases/download/3.4-alpha-custom-r2/tmux-3.4-alpha.tar.xz"
  sha256 "54860d15df4ccb8b4668e9a7b0a7f5703d0726853799eee0799a31508e360fb2"
  license "ISC"
  revision 2

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "ncurses"
  depends_on "waltarix/customs/jemalloc"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/f5d53239f7658f8e8fbaf02535cc369009c436d6/completions/tmux"
    sha256 "b5f7bbd78f9790026bbff16fc6e3fe4070d067f58f943e156bd1a8c3c99f6a6f"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    on_macos do
      args << "--disable-utf8proc"
    end

    ncurses = Formula["ncurses"]
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")

    mkdir_p libexec/"bin"
    mv bin/"tmux", libexec/"bin/tmux"
    env = {}.tap do |e|
      libjemalloc = Formula["jemalloc"].opt_lib/shared_library("libjemalloc")
      on_macos { e[:DYLD_INSERT_LIBRARIES] = libjemalloc }
      on_linux { e[:LD_PRELOAD] = libjemalloc }
    end
    (bin/"tmux").write_env_script libexec/"bin/tmux", env
  end

  def caveats
    <<~EOS
      Example configuration has been installed to:
        #{opt_pkgshare}
    EOS
  end

  test do
    system bin/"tmux", "-V"

    require "pty"

    socket = testpath/tap.user
    PTY.spawn bin/"tmux", "-S", socket, "-f", "/dev/null"
    sleep 10

    assert_predicate socket, :exist?
    assert_predicate socket, :socket?
    assert_equal "no server running on #{socket}", shell_output("#{bin}/tmux -S#{socket} list-sessions 2>&1", 1).chomp
  end
end
