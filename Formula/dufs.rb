class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  "0.34.2".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "6297cfef919456859d7d8b026b13fcf507c0ec939a2d4d28f934d055f21299a1"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "88b650b05b81c4434b519d704754bfadfc0b5093ba929d141ca2f3433089d7d4"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "ca6372ea5155ee11a1df500f279d03fd1d51495ae477bf3180c22bdaf3d0aeef"
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
