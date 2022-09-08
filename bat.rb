class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.22.0-custom/bat-0.22.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "509d482d49b12f71cba8a8638fa35c49b4ee0c5ebf401762d57b3f27f3f56b64"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.22.0-custom/bat-0.22.0-aarch64-apple-darwin.tar.xz"
      sha256 "5dba370f75077dc3b1a1c9eeddf928120405b7b79e8470738c4e87559bac2fd9"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.22.0-custom/bat-0.22.0-x86_64-apple-darwin.tar.xz"
      sha256 "45d3de167375c7e17315cecfd7cbca7fd7b2194e1772bde837e186451a2bec66"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

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
