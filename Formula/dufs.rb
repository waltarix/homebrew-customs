class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  "0.38.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "5fb7153ceca2c24fcd4b5225597a3b5303a16005571e075f7103b558e72026d8"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "4775742d8b34c028954cf00b91e3bb6afa1de4f6ae12a6fe5a0d4818a899b0b5"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "023d7798dd0161f26027c203a628acced5af5d0d5954a94a74224ee753d3adc2"
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
