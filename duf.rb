class Duf < Formula
  desc "Disk Usage/Free Utility - a better 'df' alternative"
  homepage "https://github.com/muesli/duf"
  if OS.linux?
    url "https://github.com/waltarix/duf/releases/download/v0.5.0-custom-r1/duf-0.5.0-linux_amd64.tar.xz"
    sha256 "9691b8092d86d4a6493e40089f416eea3619b6f6c5673f36b18a1cda521de4e8"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/duf/releases/download/v0.5.0-custom-r1/duf-0.5.0-darwin_arm64.tar.xz"
      sha256 "b5795c2bf57a5bf874b301d0461aa5a3635e83d4472b791d70e10385767a71b3"
    else
      url "https://github.com/waltarix/duf/releases/download/v0.5.0-custom-r1/duf-0.5.0-darwin_amd64.tar.xz"
      sha256 "51dd6a60a7840550999aac3a140da712bc0df15c9708dca6ac31dc4126650802"
    end
  end
  version "0.5.0"
  license "MIT"
  revision 1

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
