class Duf < Formula
  desc "Disk Usage/Free Utility - a better 'df' alternative"
  homepage "https://github.com/muesli/duf"
  if OS.linux?
    url "https://github.com/waltarix/duf/releases/download/v0.7.0-custom/duf-0.7.0-linux_amd64.tar.xz"
    sha256 "1ca53bc1d07070ca3adefef8226b5296ffcfce37b862041faa54d4a7b773948c"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/duf/releases/download/v0.7.0-custom/duf-0.7.0-darwin_arm64.tar.xz"
      sha256 "a572e6376990c2a4180a98a3b76965c46b4f5b76af14ce3f0854e5ad9519310b"
    else
      url "https://github.com/waltarix/duf/releases/download/v0.7.0-custom/duf-0.7.0-darwin_amd64.tar.xz"
      sha256 "ac6e9b1d207c2a6d92f22512cad0958e107595bd41b650abe3c4632f2ee014b4"
    end
  end
  version "0.7.0"
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
