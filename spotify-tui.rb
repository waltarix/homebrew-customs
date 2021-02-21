class SpotifyTui < Formula
  desc "Terminal-based client for Spotify"
  homepage "https://github.com/Rigellute/spotify-tui"
  if OS.linux?
    url "https://github.com/waltarix/spotify-tui/releases/download/v0.23.0-custom-r1/spotify-tui-0.23.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "4760c6982a170e93bf286020cf1834acad435e96d37b7afb6e6a2083b54f1283"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.23.0-custom-r1/spotify-tui-0.23.0-aarch64-apple-darwin.tar.xz"
      sha256 "33e65acd493a5ba4f907d9892816637cc948df9d511691dafebeef27a55c7869"
    else
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.23.0-custom-r1/spotify-tui-0.23.0-x86_64-apple-darwin.tar.xz"
      sha256 "c39b8c96c21d23381b54db5b8ceae71b43a08b46dea84e33a8e1578ad56c4654"
    end
  end
  license "MIT"
  revision 1
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
