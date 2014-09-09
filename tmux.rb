require 'formula'

class Tmux < Formula
  homepage 'http://tmux.sourceforge.net'
  url 'https://downloads.sourceforge.net/project/tmux/tmux/tmux-1.9/tmux-1.9a.tar.gz'
  sha1 '815264268e63c6c85fe8784e06a840883fcfc6a2'

  head do
    url 'git://git.code.sf.net/p/tmux/tmux-code'

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on 'pkg-config' => :build
  depends_on 'libevent'

  def patches
    [
      'https://gist.github.com/waltarix/1399751/raw/8c5f0018c901f151d39680ef85de6d22649b687a/tmux-ambiguous-width-cjk.patch',
      'https://gist.github.com/waltarix/1399751/raw/eb7277a3105bbf6312119c03ac96e864421e3cf8/tmux-do-not-combine-utf8.patch',
      'https://gist.github.com/waltarix/1399751/raw/dc11f40266d9371e730eff41c64a70c84d34484a/tmux-pane-border-ascii.patch'
    ]
  end

  def install
    system "sh", "autogen.sh" if build.head?

    ENV.append "LDFLAGS", '-lresolv'
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
