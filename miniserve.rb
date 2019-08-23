class Miniserve < Formula
  desc "High performance static file server"
  homepage "https://github.com/svenstaro/miniserve"
  url "file:///dev/null"
  version "0.5.0"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  resource "miniserve" do
    url "https://github.com/svenstaro/miniserve/releases/download/v0.5.0/miniserve-osx-x86_64"
    sha256 "55b28b0ef52523e5648bd8610b4584d42aaed2008ed0315d3d2e5de39144e7bc"
  end

  def install
    resource("miniserve").stage do
      bin.install "miniserve-osx-x86_64" => "miniserve"
    end
  end

  test do
    require "socket"

    server = TCPServer.new(0)
    port = server.addr[1]
    server.close

    pid = fork do
      exec "#{bin}/miniserve", "#{bin}/miniserve", "-i", "127.0.0.1", "--port", port.to_s
    end

    sleep 2

    begin
      read = (bin/"miniserve").read
      assert_equal read, shell_output("curl localhost:#{port}")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
