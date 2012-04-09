require 'formula'

class Tmux < Formula
  url 'http://sourceforge.net/projects/tmux/files/tmux/tmux-1.6/tmux-1.6.tar.gz'
  md5 '3e37db24aa596bf108a0442a81c845b3'
  homepage 'http://tmux.sourceforge.net'

  head 'https://tmux.svn.sourceforge.net/svnroot/tmux/trunk'

  depends_on 'libevent'

  if ARGV.build_head? and MacOS.xcode_version >= "4.3"
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def patches
    [
      'https://gist.github.com/raw/1399751/3bd3d1d4a9a246bc0e0016b2cfab91f3c1937a2f/tmux-ambiguous-width-cjk.patch',
      'https://gist.github.com/raw/1399751/1bf63c51f01853c228846e1478fe203e400a6dc1/tmux-do-not-combine-utf8.patch'
    ]
  end

  def install
    system "sh", "autogen.sh" if ARGV.build_head?

    ENV.append "LDFLAGS", '-lresolv'
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    system "make install"

    # Install bash completion scripts for use with bash-completion
    (prefix+'etc/bash_completion.d').install "examples/bash_completion_tmux.sh" => 'tmux'
  end

  def caveats; <<-EOS.undent
    Bash completion script was installed to:
      #{etc}/bash_completion.d/tmux
    EOS
  end

  def test
    system "#{bin}/tmux -V"
  end
end
