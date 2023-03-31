class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  "1.7.1".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/et-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "41f5b5105d90289c36b8069fd9fcd2665d0c277db0c41a3e39565f7cb5f80553"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/et-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "13da3df7d37dd22692be051d4989525b377d3816b95e4c17150ae9f059fcf056"
      else
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/et-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "8c3d1944ac6d47dd106a57db47937f60f9605a937f2a7a4f1f0773c86103a250"
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
