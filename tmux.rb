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
      'https://gist.githubusercontent.com/waltarix/1399751/raw/e60e879335bf3b91fef4592b194cc524bcb95388/tmux-ambiguous-width-cjk.patch',
      'https://gist.githubusercontent.com/waltarix/1399751/raw/d581fc517db8173581e4518e2025916a5cf5de09/tmux-do-not-combine-utf8.patch',
      'https://gist.githubusercontent.com/waltarix/1399751/raw/5914827c8f7fecfdb73c641e02c471acd55eb2af/tmux-pane-border-ascii.patch',
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
