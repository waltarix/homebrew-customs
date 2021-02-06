class Duf < Formula
  desc "Disk Usage/Free Utility - a better 'df' alternative"
  homepage "https://github.com/muesli/duf"
  if OS.linux?
    url "https://github.com/waltarix/duf/releases/download/v0.6.0-custom/duf-0.6.0-linux_amd64.tar.xz"
    sha256 "de81ccb81a4749f6f106bf01c5cfe89eefed9e14ca8baecaa1e76f656e7e2b20"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/duf/releases/download/v0.6.0-custom/duf-0.6.0-darwin_arm64.tar.xz"
      sha256 "67dc1659def79a6420f5442f1a674e1db3bad591bacbe771e9f5f40b69680bd0"
    else
      url "https://github.com/waltarix/duf/releases/download/v0.6.0-custom/duf-0.6.0-darwin_amd64.tar.xz"
      sha256 "6b73b2c40e403fbeff66c98817b7399525c21ff528eea1eca015eb8ca263c229"
    end
  end
  version "0.6.0"
  license "MIT"

  bottle :unneeded

  def install
    bin.install "duf"
  end

  test do
    require "json"

    devices = JSON.parse shell_output("#{bin}/duf --json")
    assert root = devices.find { |d| d["mount_point"] == "/" }
    assert_equal "local", root["device_type"]
  end
end
