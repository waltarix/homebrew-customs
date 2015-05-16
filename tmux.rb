require 'formula'

class Tmux < Formula
  homepage 'http://tmux.sourceforge.net'
  url 'https://downloads.sourceforge.net/project/tmux/tmux/tmux-2.0/tmux-2.0.tar.gz'
  sha1 '977871e7433fe054928d86477382bd5f6794dc3d'

  bottle do
    cellar :any
    sha256 "91a14274005416c9a20f64f149f732837b0503c0ddcfdc80f87c0576e99ee3fa" => :yosemite
    sha256 "d70b62ddf26d2113a108622643550dc50248c98188af27d7e2e76e415f43588d" => :mavericks
    sha256 "a1468fd6ac69c18c4773a65c11b2811525d542d911f6c6642e87c0e195f6c4c1" => :mountain_lion
  end

  def pour_bottle?
    false
  end

  head do
    url 'git://git.code.sf.net/p/tmux/tmux-code'

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on 'pkg-config' => :build
  depends_on 'libevent'
  depends_on 'homebrew/dupes/ncurses'

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1399751/raw/d3c9f57e7c22f3b5303c23520b434dc33313f7a5/tmux-ambiguous-width-cjk.patch"
    sha256 "f2c47a70734205b3200d47a6dc838717aa19c7d4bcc601aa3c625838e9301ab0"
  end

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1399751/raw/c53aff0a0c51f0b1be5c9d46b4e3807fe3560dbb/tmux-do-not-combine-utf8.patch"
    sha256 "d1fbf914f734ea94641efe28476f428f3bc2d6fb04a0eb43114084f0526b229d"
  end

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1399751/raw/289974e9b9e538d6afcd641935a14e108eae69a7/tmux-pane-border-ascii.patch"
    sha256 "f2838066b2765a19c0d4421beb885302b9e4dba94cb8b9419a58a51da5a781cb"
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
    system "make install"

    bash_completion.install "examples/bash_completion_tmux.sh" => 'tmux'
    (share/'tmux').install "examples"
  end

  def caveats; <<-EOS.undent
    Example configurations have been installed to:
      #{share}/tmux/examples
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
