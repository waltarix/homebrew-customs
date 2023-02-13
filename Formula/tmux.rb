class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/waltarix/tmux/releases/download/3.3a-custom-r2/tmux-3.3a.tar.xz"
  sha256 "0fbbd7ab934e59530390402d9f55cddde2252dd9e3ad9185feeba64294987b82"
  license "ISC"
  revision 3

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+[a-z]?)["' >]}i)
  end

  depends_on "pkg-config" => :build
  depends_on "jemalloc"
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/f5d53239f7658f8e8fbaf02535cc369009c436d6/completions/tmux"
    sha256 "b5f7bbd78f9790026bbff16fc6e3fe4070d067f58f943e156bd1a8c3c99f6a6f"
  end

  patch do
    url "https://raw.githubusercontent.com/NixOS/nixpkgs/2821a121dc2acf2fe07d9636ee35ff61807087ea/pkgs/tools/misc/tmux/CVE-2022-47016.patch"
    sha256 "c1284aace9231e736ace52333ec91726d3dfda58d3a3404b67c6f40bf5ed28a4"
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

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

    system "make", "install"

    (libexec/"bin").install bin/"tmux"
    (bin/"tmux").write_env_script libexec/"bin/tmux",
                                  ld_preload => Formula["jemalloc"].lib/shared_library("libjemalloc")

    pkgshare.install "example_tmux.conf"
    bash_completion.install resource("completion")
  end

  def caveats
    <<~EOS
      Example configuration has been installed to:
        #{opt_pkgshare}

      To prevent jemalloc from being injected into child processes,
      add the following to your tmux.conf:
        set-environment -g -r #{ld_preload}
    EOS
  end

  def ld_preload
    on_macos do
      return :DYLD_INSERT_LIBRARIES
    end
    on_linux do
      return :LD_PRELOAD
    end
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
