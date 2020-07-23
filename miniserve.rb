class Miniserve < Formula
  desc "High performance static file server"
  homepage "https://github.com/svenstaro/miniserve"
  if OS.linux?
    url "https://github.com/svenstaro/miniserve/releases/download/v0.8.0/miniserve-v0.8.0-linux-x86_64"
    sha256 "9f6d92a7643717a5be4487894a427cfa2d4c61d40213257d0aae16731708575b"
  else
    url "https://github.com/svenstaro/miniserve/releases/download/v0.8.0/miniserve-v0.8.0-macos-x86_64"
    sha256 "b6797ff7435b894a976e1927caed445044f96f575f3cc1e7f0bc91c4a0b6430f"
  end
  version "0.8.0"
  license "MIT"

  bottle :unneeded

  def install
    bin.install Dir["miniserve-*-x86_64"].first => "miniserve"
  end

  test do
    port = free_port
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
