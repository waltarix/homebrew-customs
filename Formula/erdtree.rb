class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  if OS.linux?
    url "https://github.com/waltarix/erdtree/releases/download/v1.4.1-custom/et-1.4.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "dd597a5b6b4c827460218ed4f48328dbcac62be96be26218a40a6bd292c0bfcc"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/erdtree/releases/download/v1.4.1-custom/et-1.4.1-aarch64-apple-darwin.tar.xz"
      sha256 "cc964f3efbd4fe6ad9f80b8fa43dcd569afdafdc36ee30785716928e48303b4d"
    else
      url "https://github.com/waltarix/erdtree/releases/download/v1.4.1-custom/et-1.4.1-x86_64-apple-darwin.tar.xz"
      sha256 "3f3ae5b576ac345cf5448b3c656a5438367d3a397d5da14ae7a9336da320302c"
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
