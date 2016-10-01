class Tmux < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"
  url "https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz"
  sha256 "55313e132f0f42de7e020bf6323a1939ee02ab79c48634aa07475db41573852b"

  bottle do
    cellar :any
    sha256 "61149e67e9dbbbe9dd88d347582883cfabbaeb314368c53d19dff4fe4d2aeb12" => :sierra
    sha256 "a0964ec917ea8fe42f82348d1bee599f93ffefba1e1910dd13c101b5155cd203" => :el_capitan
    sha256 "1705df1d70791c49ab907dab166e573848c435d4c56787be664347dbfa50edcd" => :yosemite
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
  depends_on "homebrew/dupes/ncurses"
  depends_on "waltarix/customs/wcwidth-cjk"

  stable do
    patch :p1 do
      url "https://gist.githubusercontent.com/waltarix/1399751/raw/6c8f54ec8e55823fb99b644a8a5603847cb60882/tmux-pane-border-ascii.patch"
      sha256 "2019e69de97882b11ba0bf0dcbf29d25f4744576a33ad9909a62329609bfdf40"
    end
  end

  resource "completion" do
    url "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/homebrew_1.0.0/completions/tmux"
    sha256 "05e79fc1ecb27637dc9d6a52c315b8f207cf010cdcee9928805525076c9020ae"
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
