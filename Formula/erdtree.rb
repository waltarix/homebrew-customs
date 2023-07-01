class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  "3.1.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "ad096d778b39bcaa37389f9e468a56a5b56f799a15f46e2aab67ad1ac3534db3"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "aa0952c9be8e8e6fec0a226b1160f8458263b04a1bc5a97bf3efa768414606da"
      else
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "360918db05ff16f8850b2d5ca371e0cfcb5bf0a9ceb6947a912624b3d24045fa"
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
