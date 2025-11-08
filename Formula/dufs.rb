class Dufs < Formula
  desc "Static file server"
  homepage "https://github.com/sigoden/dufs"
  ["0.45.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "32fdb9797fb663db98727060a1e50771e975b696ff677e0b839ae7abf64e1f5e"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "1ddd639242aa77d155ae5d97a51397c202d2df1920e31b2363952f76be8b5cc9"
      else
        url "https://github.com/waltarix/dufs/releases/download/v#{v}-custom#{rev}/dufs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "99c0ec33104f1a2602fe1584065d71f70d87a48f8d0d8adad9be0a254c0c9aed"
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
