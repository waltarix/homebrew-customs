class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  ["0.44.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "2ff6fb37620ff104e10117db8118fd853a9bb479c462ad739969f03c31d7b285"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "d0058e64d3c4310e33e80a296e4bce2497a4461140d1d60c6a58f09e0a7f1c34"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "b1ef2008c67a8e351f35e1527ca9c7b6f00ff87f25343572f8255571ed0bfcbd"
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
