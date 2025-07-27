class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  ["0.43.0", 1].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "81134ac4b805c59381bb23087e25528b8140af3ddac6c3e2065950df549cc924"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "913e605a37f34be1e3ef8d3fc80a2305ddf2a1c3eca8c90502c750959b146e24"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "11b9a948a5a0ce9e72f4c915019e6b6a4d210406f53124c04c96961acc911e0e"
      end
    end
    revision r if r
  end
  license any_of: ["Apache-2.0", "MIT"]

  def install
    bin.install "dufs"

    generate_completions_from_executable(bin/"dufs", "--completions")
  end

  test do
    port = free_port
    pid = fork do
      exec bin/"dufs", bin.to_s, "-b", "127.0.0.1", "--port", port.to_s
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
