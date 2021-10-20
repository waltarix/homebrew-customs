class Duf < Formula
  desc "Disk Usage/Free Utility - a better 'df' alternative"
  homepage "https://github.com/muesli/duf"
  if OS.linux?
    url "https://github.com/waltarix/duf/releases/download/v0.6.2-custom/duf-0.6.2-linux_amd64.tar.xz"
    sha256 "15e4f0417a84d7342a188c8092a04dd28df5f7d567ac20489c39511dd26b4332"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/duf/releases/download/v0.6.2-custom/duf-0.6.2-darwin_arm64.tar.xz"
      sha256 "81e66e4ecfc23ce87bbc3d1022280c917a1793ecf1330ad468c6c0b0988caf14"
    else
      url "https://github.com/waltarix/duf/releases/download/v0.6.2-custom/duf-0.6.2-darwin_amd64.tar.xz"
      sha256 "33b29146cfd1390659931129d5fa4b8bf49d77ae0f9710c22d10c5b4a1211f71"
    end
  end
  version "0.6.2"
  license "MIT"

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
