class Mprocs < Formula
  desc "Run multiple commands in parallel"
  homepage "https://github.com/pvolok/mprocs"
  if OS.linux?
    url "https://github.com/waltarix/mprocs/releases/download/v0.6.4-custom/mprocs-0.6.4-x86_64-unknown-linux-musl.tar.xz"
    sha256 "7160890061b0784f23199e098bd77e240d8a2564bb39c4a23ccf75c607f6a395"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.4-custom/mprocs-0.6.4-aarch64-apple-darwin.tar.xz"
      sha256 "bb58656bc350b763d0041c427605c604748918c852a0a98e587d764d7b42f57e"
    else
      url "https://github.com/waltarix/mprocs/releases/download/v0.6.4-custom/mprocs-0.6.4-x86_64-apple-darwin.tar.xz"
      sha256 "433f27caf76d0de1768a9af9800e12019a47728aec7811dcf6dc63867f41d824"
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
