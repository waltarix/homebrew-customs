class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  if OS.linux?
    url "https://github.com/waltarix/erdtree/releases/download/v1.5.2-custom/et-1.5.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "f5989c4eda70b70e0af8e0feb827aa62aaed2fa922dc749a76e37a1d2b994539"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/erdtree/releases/download/v1.5.2-custom/et-1.5.2-aarch64-apple-darwin.tar.xz"
      sha256 "7abf923551cfd6932f51d0c4d236e4da58d643a9b023ea09ee95c0079659cb45"
    else
      url "https://github.com/waltarix/erdtree/releases/download/v1.5.2-custom/et-1.5.2-x86_64-apple-darwin.tar.xz"
      sha256 "a7bc3bfab9f08690bbe8445614dcd260ed6c9e5fb43124f009cd2d8b3e7efdcc"
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
