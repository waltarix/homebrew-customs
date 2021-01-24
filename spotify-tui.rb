class SpotifyTui < Formula
  desc "Terminal-based client for Spotify"
  homepage "https://github.com/Rigellute/spotify-tui"
  if OS.linux?
    url "https://github.com/waltarix/spotify-tui/releases/download/v0.23.0-custom/spotify-tui-0.23.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "fd12d648782abbda6e448a5fddff5f218cc9a4aab8d34433c02ceea3c0527f1a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.23.0-custom/spotify-tui-0.23.0-aarch64-apple-darwin.tar.xz"
      sha256 "2ea1ae0eda4eedcae7f1efb4b7410184da1a549b5a9a4f6bab7815c0a5618711"
    else
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.23.0-custom/spotify-tui-0.23.0-x86_64-apple-darwin.tar.xz"
      sha256 "875eba9f2fcd6c9acf180c9911b1bfce68ae634d7fd861aa7f0d66b9dcab55ea"
    end
  end
  license "MIT"
  head "https://github.com/Rigellute/spotify-tui.git"

  livecheck do
    url :stable
  end

  bottle :unneeded

  def install
    bin.install "spt"
  end

  test do
    pid = fork { exec "#{bin}/spt -c #{testpath/"client.yml"} 2>&1 > output" }
    sleep 2
    Process.kill "TERM", pid
    assert_match /Enter your Client ID/, File.read("output")
  end
end
