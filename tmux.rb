class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"

  stable do
    url "https://github.com/tmux/tmux/releases/download/2.1/tmux-2.1.tar.gz"
    sha256 "31564e7bf4bcef2defb3cb34b9e596bd43a3937cad9e5438701a81a5a9af6176"

    patch do
      # This fixes the Tmux 2.1 update that broke the ability to use select-pane [-LDUR]
      # to switch panes when in a maximized pane https://github.com/tmux/tmux/issues/150#issuecomment-149466158
      url "https://github.com/tmux/tmux/commit/a05c27a7e1c4d43709817d6746a510f16c960b4b.diff"
      sha256 "2a60a63f0477f2e3056d9f76207d4ed905de8a9ce0645de6c29cf3f445bace12"
    end
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

  depends_on 'pkg-config' => :build
  depends_on 'libevent'
  depends_on 'homebrew/dupes/ncurses'

  stable do
    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/695586fad1664f500df9a22622a6ff52c262c3eb/tmux-ambiguous-width-cjk.patch"
      sha256 "943a1d99dc76c3bdde82b24ecca732f0410c3e58dba39396cc7f87c9635bc37c"
    end

    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/695586fad1664f500df9a22622a6ff52c262c3eb/tmux-do-not-combine-utf8.patch"
      sha256 "71f4b983083dfbea1ee104ee9538dd96d979843e4100ffa71b069bfd51d9289c"
    end

    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/695586fad1664f500df9a22622a6ff52c262c3eb/tmux-pane-border-ascii.patch"
      sha256 "50dc763b4933e77591bf2f79cd432613c656725156ad21166d77814dfefd1952"
    end
  end

  head do
    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/e2c3b43503507c6002d6cb169ddd098b755a427e/tmux-ambiguous-width-cjk.patch"
      sha256 "70de4069b87c9e6cb0f8420672aa55546ac6ca5290527a1b6576e0db7d0b1b0b"
    end

    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/e2c3b43503507c6002d6cb169ddd098b755a427e/tmux-do-not-combine-utf8.patch"
      sha256 "aa05d74c7078bc622cfba8e16141a01f0c807d5a2708f76d14e40b33ee0afa6e"
    end

    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/e2c3b43503507c6002d6cb169ddd098b755a427e/tmux-pane-border-ascii.patch"
      sha256 "2d1cde911ae7d29a30eab4ab44b9371283a3418e2706b8c9b13cbe3ae20a473c"
    end
  end

  def install
    system "sh", "autogen.sh" if build.head?

    ncurses = Formula["ncurses"]

    ENV.append "LDFLAGS", '-lresolv'
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"

    system "make", "install"

    bash_completion.install "examples/bash_completion_tmux.sh" => "tmux"
    pkgshare.install "examples"
  end

  def caveats; <<-EOS.undent
    Example configurations have been installed to:
      #{opt_pkgshare}/examples
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
