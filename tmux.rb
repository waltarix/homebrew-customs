require 'formula'

class Tmux < Formula
  homepage 'http://tmux.sourceforge.net'
  url 'http://sourceforge.net/projects/tmux/files/tmux/tmux-1.8/tmux-1.8.tar.gz'
  sha1 '08677ea914e1973ce605b0008919717184cbd033'

  head 'git://tmux.git.sourceforge.net/gitroot/tmux/tmux'

  depends_on 'pkg-config' => :build
  depends_on 'libevent'

  if build.head?
    depends_on :automake
    depends_on :libtool
  end

  def patches
    [
      'https://gist.github.com/raw/1399751/8c5f0018c901f151d39680ef85de6d22649b687a/tmux-ambiguous-width-cjk.patch',
      'https://gist.github.com/raw/1399751/eb7277a3105bbf6312119c03ac96e864421e3cf8/tmux-do-not-combine-utf8.patch',
      'https://gist.github.com/raw/1399751/dc11f40266d9371e730eff41c64a70c84d34484a/tmux-pane-border-ascii.patch'
    ]
  end

  def install
    system "sh", "autogen.sh" if build.head?

    ENV.append "LDFLAGS", '-lresolv'
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    system "make install"

    (prefix+'etc/bash_completion.d').install "examples/bash_completion_tmux.sh" => 'tmux'
  end

  def test
    system "#{bin}/tmux", "-V"
  end
end

