class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  if OS.linux?
    url "https://github.com/waltarix/dufs/releases/download/v0.32.0-custom/dufs-0.32.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "eedfb933f669c508c0d89757773961c162a52fb46c922381da5a052c17514fcb"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dufs/releases/download/v0.32.0-custom/dufs-0.32.0-aarch64-apple-darwin.tar.xz"
      sha256 "21381d0a767968912c47abf1c832cb21d35d5adccc518920e38f649d664e2d3b"
    else
      url "https://github.com/waltarix/dufs/releases/download/v0.32.0-custom/dufs-0.32.0-x86_64-apple-darwin.tar.xz"
      sha256 "e95ba5d0f0f8c1fb69b94267289d91dfe8ae6b766642ba237add1c330dc364a5"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

  def install
    bin.install "dufs"

    generate_completions_from_executable(bin/"dufs", "--completions")
  end

  test do
    port = free_port
    pid = fork do
      exec "#{bin}/dufs", bin.to_s, "-b", "127.0.0.1", "--port", port.to_s
    end

    sleep 2

    begin
      read = (bin/"dufs").read
      assert_equal read, shell_output("curl localhost:#{port}/dufs")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
