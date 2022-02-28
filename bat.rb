class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.20.0-custom/bat-0.20.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "b5adbf3e5257671eecc077f706420dc385750afddeef141d40e8f6acfb9de8b7"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.20.0-custom/bat-0.20.0-aarch64-apple-darwin.tar.xz"
      sha256 "0f4ffb2fcb212ad288f9049f77caee877d5293070b7714386782fde54f0f104b"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.20.0-custom/bat-0.20.0-x86_64-apple-darwin.tar.xz"
      sha256 "9d940ebaea27ebcb0052e8332796427b617af25288bd05c813e1cf351c81d1f9"
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
