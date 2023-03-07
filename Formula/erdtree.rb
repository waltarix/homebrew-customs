class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  if OS.linux?
    url "https://github.com/waltarix/erdtree/releases/download/v1.3.0-custom/et-1.3.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "d220475e8f4c77bcf2767de92b891934fb8387a422c2b1809e06f3f134f97625"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/erdtree/releases/download/v1.3.0-custom/et-1.3.0-aarch64-apple-darwin.tar.xz"
      sha256 "7b5683a4d0f47ce2325834ec301193f70bd067fdd3ea40ea829c3e6009ec79a8"
    else
      url "https://github.com/waltarix/erdtree/releases/download/v1.3.0-custom/et-1.3.0-x86_64-apple-darwin.tar.xz"
      sha256 "9d411a380b0bfacf48f3d1788b33e63f6991f803734de081f83f1b8a61ff2b1b"
    end
  end
  license "MIT"

  def install
    bin.install "et"
  end

  test do
    touch "test.txt"
    assert_match "test.txt", shell_output("#{bin}/et")
  end
end
