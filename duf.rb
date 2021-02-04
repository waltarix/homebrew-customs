class Duf < Formula
  desc "Disk Usage/Free Utility - a better 'df' alternative"
  homepage "https://github.com/muesli/duf"
  if OS.linux?
    url "https://github.com/waltarix/duf/releases/download/v0.5.0-custom/duf-0.5.0-linux_amd64.tar.xz"
    sha256 "45764b1e849824c55705ff33c6f2e856924bdccb54c8ff83633235993f3a1d1b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/duf/releases/download/v0.5.0-custom/duf-0.5.0-darwin_arm64.tar.xz"
      sha256 "3a9476f48d82d0f5b36c34d1b2b007dfae0525b22810b0279b967c1acac304a6"
    else
      url "https://github.com/waltarix/duf/releases/download/v0.5.0-custom/duf-0.5.0-darwin_amd64.tar.xz"
      sha256 "780b5dbf75a1b9d583df3dda765f5282de62d356d13d9a6fe174ae9a9096f7b2"
    end
  end
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
