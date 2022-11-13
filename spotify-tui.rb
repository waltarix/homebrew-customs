class SpotifyTui < Formula
  desc "Terminal-based client for Spotify"
  homepage "https://github.com/Rigellute/spotify-tui"
  if OS.linux?
    url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom-r2/spotify-tui-0.25.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "69fa4f3c4a15f25bf9fcd937fea62094422fcc35ed34749590ae7a2ee99ea3b0"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom-r2/spotify-tui-0.25.0-aarch64-apple-darwin.tar.xz"
      sha256 "21e5447a78273b248a1db6bcae02b703483c5c9a6a9c22d1c2cd9492d2086482"
    else
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom-r2/spotify-tui-0.25.0-x86_64-apple-darwin.tar.xz"
      sha256 "e8498b70a4ab6f588e951d491104aa93100a1f8843e9bd460849c6e9a6d980f7"
    end
  end
  license "MIT"
  revision 2
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
