class Duf < Formula
  desc "Disk Usage/Free Utility - a better 'df' alternative"
  homepage "https://github.com/muesli/duf"
  if OS.linux?
    url "https://github.com/waltarix/duf/releases/download/v0.8.0-custom/duf-0.8.0-linux_amd64.tar.xz"
    sha256 "4f6ec4eba86e002d37692456dc76066facdc86d10ee98c3c05bb525b57e801ad"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/duf/releases/download/v0.8.0-custom/duf-0.8.0-darwin_arm64.tar.xz"
      sha256 "dafa6d139a036ce0bdae06b5adc518db022fb139b0fa24477cad1cc70a882eb4"
    else
      url "https://github.com/waltarix/duf/releases/download/v0.8.0-custom/duf-0.8.0-darwin_amd64.tar.xz"
      sha256 "102c527ebc0f85be55893c8476620145c39abcedb70f88da158417e751c47041"
    end
  end
  version "0.8.0"
  license "MIT"

  def install
    bin.install "duf"
    man1.install "duf.1"
  end

  test do
    require "json"

    devices = JSON.parse shell_output("#{bin}/duf --json")
    assert root = devices.find { |d| d["mount_point"] == "/" }
    assert_equal "local", root["device_type"]
  end
end
