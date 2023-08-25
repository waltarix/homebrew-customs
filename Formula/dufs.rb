class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  "0.36.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "a59638ab2ece614be3200d5d34a1ed8a7812cc2c43efdb7af007fb1c58dd74b5"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "26d50b251a25ed244d74b18313028bca75e627a5c6e5b5a72fa7d6bbf17f76d2"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "cd5fced184dfbabe6306907918c12b8ac99d9a5e5ad179e1276f1922954e98e6"
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
