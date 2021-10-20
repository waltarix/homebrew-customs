class SpotifyTui < Formula
  desc "Terminal-based client for Spotify"
  homepage "https://github.com/Rigellute/spotify-tui"
  if OS.linux?
    url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom/spotify-tui-0.25.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "69d231190445cef0af45acbecfceab27edcde49dd69410ff432cb5349f6179b3"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom/spotify-tui-0.25.0-aarch64-apple-darwin.tar.xz"
      sha256 "b24d2efecef122db480cef91ce8a74b270833b45cb4c1f1daa20f353566538b7"
    else
      url "https://github.com/waltarix/spotify-tui/releases/download/v0.25.0-custom/spotify-tui-0.25.0-x86_64-apple-darwin.tar.xz"
      sha256 "f07611e29e1a3b20b6672dca930b95425a274cee0ebd6ed1dc762dc6c03b46a2"
    end
  end
  license "MIT"
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
