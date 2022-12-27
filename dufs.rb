class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  if OS.linux?
    url "https://github.com/waltarix/dufs/releases/download/v0.31.0-custom/dufs-0.31.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "a001cb73dbc9339b475e23da8695484cc64b32f59162cb2f71cfb17a73b54209"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dufs/releases/download/v0.31.0-custom/dufs-0.31.0-aarch64-apple-darwin.tar.xz"
      sha256 "18aef15372d756d7f78276934491d27bbfb03aed144ee321d16d62a3843c2f5e"
    else
      url "https://github.com/waltarix/dufs/releases/download/v0.31.0-custom/dufs-0.31.0-x86_64-apple-darwin.tar.xz"
      sha256 "3009a0e7b20c057ff29554ff31bf24b87e34246b8b26c341e8ab041a7f5e3e9e"
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
