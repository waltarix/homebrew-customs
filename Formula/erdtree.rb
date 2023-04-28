class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  "2.0.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "bf0e8ecab623c9ceb8fb4d8f5218ce3ff76e4a9a6f240579e8749d2570e60cee"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "c668a2a3c04db1ea433c753f6e32616e74a7055a2dc8e0b00c598264870bb03e"
      else
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "f86d7862f3024ae1db2505b6a4f5afba2fbda67d0aa76b72bafc7d5dd5bdcd88"
      end
    end
  end
  license "MIT"

  def install
    bin.install "erd"

    generate_completions_from_executable(bin/"erd", "--completions")
  end

  test do
    touch "test.txt"
    assert_match "test.txt", shell_output("#{bin}/erd")
  end
end
