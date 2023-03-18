class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  if OS.linux?
    url "https://github.com/waltarix/dufs/releases/download/v0.33.0-custom/dufs-0.33.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "43ae4f4549ad9a86dfacfe651b97c2fc7ab9f00825f70963bfa413745cf0bc70"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dufs/releases/download/v0.33.0-custom/dufs-0.33.0-aarch64-apple-darwin.tar.xz"
      sha256 "ba86ccea091fb74d712a69ea82314c70afb87d8d5bbbc5b4b24a9cc701093fdd"
    else
      url "https://github.com/waltarix/dufs/releases/download/v0.33.0-custom/dufs-0.33.0-x86_64-apple-darwin.tar.xz"
      sha256 "f3084ae456190808a1996e408d4261e8c2726b9c0419ddba7452e5dcab6863b7"
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
