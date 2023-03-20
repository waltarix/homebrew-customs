class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  if OS.linux?
    url "https://github.com/waltarix/erdtree/releases/download/v1.6.0-custom/et-1.6.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "27ce5c27b8bdcd86e996134f6e76acfd710b6c0611a4c1946c8cf7e676c6f5c7"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/erdtree/releases/download/v1.6.0-custom/et-1.6.0-aarch64-apple-darwin.tar.xz"
      sha256 "67613a39bf850b73691f64e71fa5ed923bf7452c4b68919a3dd4ac13648abfe7"
    else
      url "https://github.com/waltarix/erdtree/releases/download/v1.6.0-custom/et-1.6.0-x86_64-apple-darwin.tar.xz"
      sha256 "07e7255fb7b41fa671dc6d2f2b5130de5958727c38f5601b467ce06075715ba0"
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
