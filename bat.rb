class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.19.0-custom-r1/bat-0.19.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "150abd043230ab266b9250ee1c261716f97f325c720fc2936c23e85447f289e9"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.19.0-custom-r1/bat-0.19.0-aarch64-apple-darwin.tar.xz"
      sha256 "ef5dd92108a65d4179da716e249f65ce1d09466336e512b061dcd80e48801a84"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.19.0-custom-r1/bat-0.19.0-x86_64-apple-darwin.tar.xz"
      sha256 "613a8a2ce587a254295d9f130de5b1214ecb03d35f7341bf2715a12d46d4e6d0"
    end
  end
  license "Apache-2.0"
  revision 1

  uses_from_macos "zlib"

  def install
    bin.install "bat"
    man1.install "manual/bat.1"
    fish_completion.install "etc/completions/bat.fish"
    zsh_completion.install "etc/completions/bat.zsh" => "_bat"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/bat #{pdf} --color=never")
    assert_match "Homebrew test", output
  end
end
