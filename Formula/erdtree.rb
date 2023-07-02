class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  "3.1.2".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "02af93830169320befe00e331e42760fe088e9b8f6fb80d34a1daa62881bf453"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "aec79ec762b545fbc51620718c4c1d459d51132eb71310676b7168857f769435"
      else
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "8b0710173356e504e2fb51331004deb0546afdb57aaf5f4974ad2961240795af"
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
