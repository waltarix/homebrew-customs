class SpotifyTui < Formula
  desc "Terminal-based client for Spotify"
  homepage "https://github.com/Rigellute/spotify-tui"
  if OS.linux?
    url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom-r1/spotify-tui-0.25.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "8883240c297bbf14968d45449bf4fd2e8e4d08effd3ab6714fb24eb1fc8a2cac"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom-r1/spotify-tui-0.25.0-aarch64-apple-darwin.tar.xz"
      sha256 "f6391cec604d26a33dccd32a6416fd73156014b6af6b826a2c3b6a987ba1ed75"
    else
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom-r1/spotify-tui-0.25.0-x86_64-apple-darwin.tar.xz"
      sha256 "03c5df0eda05d63cc33fab162ee4d9596f074e64311536246047495d86107293"
    end
  end
  license "MIT"
  revision 1
  head "https://github.com/Rigellute/spotify-tui.git", branch: "master"

  on_linux do
    depends_on "libxcb"
    depends_on "openssl@1.1"
  end

  def install
    bin.install "spt"
  end

  test do
    output = testpath/"output"
    fork do
      $stdout.reopen(output)
      $stderr.reopen(output)
      exec "#{bin}/spt -c #{testpath}/client.yml"
    end
    sleep 10
    assert_match "Enter your Client ID", output.read
  end
end
