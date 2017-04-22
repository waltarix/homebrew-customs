class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/2.4/tmux-2.4.tar.gz"
  sha256 "757d6b13231d0d9dd48404968fc114ac09e005d475705ad0cd4b7166f799b349"

  bottle do
    sha256 "d55216b5c284afa3916606af62d7751e87aa091fea87096e4bc8b66d8d0060e1" => :sierra
    sha256 "b33e9ad74318bbe2966d439f10613a48257cd4a206d18a18a640d41fd45f4c10" => :el_capitan
    sha256 "0c73eaa301b97cb422a312beeb2964b1490e3a132ff4e2a56609845393b74c51" => :yosemite
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
  depends_on "waltarix/customs/wcwidth-cjk"

  stable do
    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/fadd3251f09a8f289b0334500106f377cb36cefc/tmux-pane-border-ascii.patch"
      sha256 "5216d7ba6529a71a1eb51642d713d83cfd8c187acfa45413a594f11ab88f1325"
    end
  end

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
  end

  def install
    system "sh", "autogen.sh" if build.head?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
    ]

    args << "--enable-utf8proc" if build.with?("utf8proc")

    ncurses = Formula["ncurses"]
    wcwidth = Formula["wcwidth-cjk"]
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"
    ENV.append "LDFLAGS", "-L#{wcwidth.lib} -lwcwidth-cjk"

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", *args

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
