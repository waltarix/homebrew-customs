class Duf < Formula
  desc "Disk Usage/Free Utility - a better 'df' alternative"
  homepage "https://github.com/muesli/duf"
  if OS.linux?
    url "https://github.com/waltarix/duf/releases/download/v0.8.1-custom/duf-0.8.1-linux_amd64.tar.xz"
    sha256 "0f25a4efce8c9ce48d197afc8880174f1d3c4f1987dc58286e9734307796afe4"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/duf/releases/download/v0.8.1-custom/duf-0.8.1-darwin_arm64.tar.xz"
      sha256 "576a522c1b875d700c8ccd10f6c6f1f98043329a95595529c432a1618c7490de"
    else
      url "https://github.com/waltarix/duf/releases/download/v0.8.1-custom/duf-0.8.1-darwin_amd64.tar.xz"
      sha256 "b3672016019e360a9dbc46e10da7e9697ec9c4e9a93d6607d7294e544e00a0f2"
    end
  end
  version "0.8.1"
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
