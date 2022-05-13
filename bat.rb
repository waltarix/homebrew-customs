class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.21.0-custom/bat-0.21.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "b6e8f93ee80774259c55344ef1119215bf929fc16b07943b2a633455ab283d9f"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.21.0-custom/bat-0.21.0-aarch64-apple-darwin.tar.xz"
      sha256 "47b47c0a7fd22164c549cdf68ac9bd9d6b63059aa954ae2431ab1fd92657e101"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.21.0-custom/bat-0.21.0-x86_64-apple-darwin.tar.xz"
      sha256 "bbf692feae9f8d26398e9882dd7b3119c9c3fb30faadeccd61fd92d3eeb4dd18"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

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
