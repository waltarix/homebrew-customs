class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  "0.35.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "4078be0c8e932330783bf4950464b3c38265f68db229da1d63e659b2a846de66"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "d61c2d17e43dfc8304cf2b4dcf44d73c2201fb6acddf153412c9a617f2dbbe9e"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "e2c0656429c335a55e9bdcd7832782477f84f67559cf43173f2793772b2b74a4"
      end
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
