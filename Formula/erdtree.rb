class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  "1.8.1".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/et-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "8690328c5fbef473ea631dc18ec2d4c74383c95bff363765b8b7ee3e3c74d2f1"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/et-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "e6aaa811c28bcc47a1de9c3d37a8eb120be3079fa493999ac4b321b64124afbf"
      else
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/et-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "08fbcd6a21068a94c3c4bccd16f2012140806872481ac60cdf2a7b0cfd9a27b2"
      end
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
