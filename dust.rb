class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom/dust-0.8.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "fb42c94ea030d14927bdc92a95447f4ae86cf1cb7d9094965ab4bfae46744640"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom/dust-0.8.2-aarch64-apple-darwin.tar.xz"
      sha256 "66e374311ce2a4bae4e0b1fc9b2792b7574ddd2835703cee688283d51a226256"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom/dust-0.8.2-x86_64-apple-darwin.tar.xz"
      sha256 "04e4a54cdb74759a29a43e49a6d57658925640fca44b18889d70738a40a9722f"
    end
  end
  license "Apache-2.0"
  head "https://github.com/bootandy/dust.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install "dust"
    bash_completion.install "etc/completions/dust.bash" => "dust"
    fish_completion.install "etc/completions/dust.fish"
    zsh_completion.install "etc/completions/_dust"
  end

  test do
    assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
  end
end
