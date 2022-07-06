class Mprocs < Formula
  desc "Run multiple commands in parallel"
  homepage "https://github.com/pvolok/mprocs"
  if OS.linux?
    url "https://github.com/waltarix/mprocs/releases/download/v0.6.0-custom/mprocs-0.6.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "f75be2a99ada22d4e1f0b04566496f588bbed87a65d5331aa1bffc124fe8259a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.0-custom/mprocs-0.6.0-aarch64-apple-darwin.tar.xz"
      sha256 "a27067848e53f0dcc6319673c7116c058a35adde6974320517c737ddb76f7843"
    else
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.0-custom/mprocs-0.6.0-x86_64-apple-darwin.tar.xz"
      sha256 "4b88bee7709e179d1bde0501e5cc484bf87b0ef1017ed49feb926111fcc0aebe"
    end
  end
  license "MIT"

  def install
    bin.install "mprocs"
  end

  test do
    require "pty"

    begin
      r, w, pid = PTY.spawn("#{bin}/mprocs 'echo hello mprocs'")
      r.winsize = [80, 30]
      sleep 1
      w.write "q"
      assert_match "hello mprocs", r.read
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    end
  ensure
    Process.kill("TERM", pid)
  end
end
