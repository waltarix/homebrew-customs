class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/waltarix/tmux/releases/download/3.5a-custom/tmux-3.5a.tar.xz"
  sha256 "5b6d3644c524d72cc0c86ee17e0cace8704677e8395fb645b45ff9827e7b5403"
  license "ISC"

  depends_on "bison" => :build
  depends_on "pkg-config" => :build
  depends_on "jemalloc"
  depends_on "libevent"
  depends_on "ncurses"

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/8da7f797245970659b259b85e5409f197b8afddd/completions/tmux"
    sha256 "4e2179053376f4194b342249d75c243c1573c82c185bfbea008be1739048e709"
  end

  patch :DATA

  def install
    args = %W[
      --enable-sixel
      --disable-utf8proc
      --sysconfdir=#{etc}
    ]

    ncurses = Formula["ncurses"]
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append_to_cflags "-flto"
    ENV.append_to_cflags "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args, *std_configure_args

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
