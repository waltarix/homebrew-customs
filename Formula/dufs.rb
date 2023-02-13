class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  if OS.linux?
    url "https://github.com/waltarix/dufs/releases/download/v0.31.0-custom-r1/dufs-0.31.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "665292b46687d700efcd869ce4156bebad506c6e9112d5776148a75ecd609ecc"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dufs/releases/download/v0.31.0-custom-r1/dufs-0.31.0-aarch64-apple-darwin.tar.xz"
      sha256 "b600f0cb4a46453500a42e3ce1b5652828140fb679dc6683f40472061fed66f4"
    else
      url "https://github.com/waltarix/dufs/releases/download/v0.31.0-custom-r1/dufs-0.31.0-x86_64-apple-darwin.tar.xz"
      sha256 "382ca04837f6ea686578a197626b718031910616f72259ddf78241e205596120"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]
  revision 1

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
