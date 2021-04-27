class SpotifyTui < Formula
  desc "Terminal-based client for Spotify"
  homepage "https://github.com/Rigellute/spotify-tui"
  if OS.linux?
    url "https://github.com/waltarix/spotify-tui/releases/download/v0.24.0-custom/spotify-tui-0.24.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "2bd1959a07cb4b53fbb048bdfa9274acb34603721a82577b5772d115e5aa3dfb"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.24.0-custom/spotify-tui-0.24.0-aarch64-apple-darwin.tar.xz"
      sha256 "70d95fab1a0ffa14c68a3903a81872829a1704db7c8fe60b56bbd84d00f7cfbd"
    else
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.24.0-custom/spotify-tui-0.24.0-x86_64-apple-darwin.tar.xz"
      sha256 "7e36fb383eafcdfab9694417a0f73904c008b335586d4adbe633b610083a5c56"
    end
  end
  license "MIT"
  head "https://github.com/Rigellute/spotify-tui.git"

  bottle :unneeded

  def install
    bin.install "spt"
  end

  test do
    pid = fork { exec "#{bin}/spt -c #{testpath/"client.yml"} 2>&1 > output" }
    sleep 10
    assert_match "Enter your Client ID", File.read("output")
  ensure
    Process.kill "TERM", pid
    quiet_system "pkill", "-9", "-f", "spt"
  end
end
