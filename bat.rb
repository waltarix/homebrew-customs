class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.22.1-custom/bat-0.22.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "45fb1affc90d61f32cea2fd840676310cbf1f6119b961aee3d5d345f7a6e76a3"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.22.1-custom/bat-0.22.1-aarch64-apple-darwin.tar.xz"
      sha256 "c7ce71496dc752c53a9802a013b329344950b9504d943dfc5ccd5fcd7a1f6bae"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.22.1-custom/bat-0.22.1-x86_64-apple-darwin.tar.xz"
      sha256 "38e2a776495a8bc18c8b1e516a143620a9413fd22ba028f8bbafd3a80951aced"
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
