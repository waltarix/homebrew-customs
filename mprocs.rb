class Mprocs < Formula
  desc "Run multiple commands in parallel"
  homepage "https://github.com/pvolok/mprocs"
  if OS.linux?
    url "https://github.com/waltarix/mprocs/releases/download/v0.6.3-custom/mprocs-0.6.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "aeab3271930a5cd88eed695f6f17c678718d8db2f6b98cfc40ef041481b3b0a2"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.3-custom/mprocs-0.6.3-aarch64-apple-darwin.tar.xz"
      sha256 "2f20eeb02dcf6e1f9f46d58a81882aa0a9ce6c0db6963710bf5b502e1a010116"
    else
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.3-custom/mprocs-0.6.3-x86_64-apple-darwin.tar.xz"
      sha256 "2c9f67d5957ea1195b3a2f8186899f744e9c4af4748fe436581298cc452fcb40"
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
