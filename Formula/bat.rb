class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.22.1-custom-r1/bat-0.22.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "9d53955a8ad7d7bea555f16869095d2286eac4a2ccf8ee104b8c6651e869ddfb"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.22.1-custom-r1/bat-0.22.1-aarch64-apple-darwin.tar.xz"
      sha256 "ddba7d42971b0f9d806dd644f1ef6c46fa309351380866fc9ddf3ca14b0f2c74"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.22.1-custom-r1/bat-0.22.1-x86_64-apple-darwin.tar.xz"
      sha256 "ee198fb9def17c60947e14eb10adb94098294a087c1aab1ae1a35fddcda9deba"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]
  revision 1

  def install
    bin.install "bat"
    man1.install "manual/bat.1"
    bash_completion.install "etc/completions/bat.bash" => "bat"
    fish_completion.install "etc/completions/bat.fish"
    zsh_completion.install "etc/completions/bat.zsh" => "_bat"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/bat #{pdf} --color=never")
    assert_match "Homebrew test", output
  end
end
