class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  "0.43.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "3b7770eb348ab5fa4babc3fea8e42c23ad217a2e4501db47d78272b60e1ab170"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "2feb31b4263dc58c5a1d966f0669e4ab0cf30446d39c6cc0cdaf7bf45fb63598"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "fdb21738291cc4812a31f35e56f31be5a6c74e8778440d0f588f7049d5ca8205"
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
