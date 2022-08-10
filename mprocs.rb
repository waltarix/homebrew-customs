class Mprocs < Formula
  desc "Run multiple commands in parallel"
  homepage "https://github.com/pvolok/mprocs"
  if OS.linux?
    url "https://github.com/waltarix/mprocs/releases/download/v0.6.2-custom/mprocs-0.6.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "bb283d6a8f878cfdb8cc1567939ae76bf8dcf68dc87d3d615f59cbebfd39625d"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.2-custom/mprocs-0.6.2-aarch64-apple-darwin.tar.xz"
      sha256 "91818231853359f8441f7c93928844930322d581c10f44a5d58e1ec543197d98"
    else
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.2-custom/mprocs-0.6.2-x86_64-apple-darwin.tar.xz"
      sha256 "db5e7efe5ac9a1386e994c51b162ffd28eae062d5caf4e0b1dcc0108216dd004"
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
