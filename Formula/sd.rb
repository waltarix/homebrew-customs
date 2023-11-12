class Sd < Formula
  desc "Intuitive find & replace CLI"
  homepage "https://github.com/chmln/sd"
  "1.0.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/sd/releases/download/v#{v}-custom/sd-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "ad4062e6c1c518d4cefb18114be07ee7ec3f6c904fbafc696209da01644218ca"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/sd/releases/download/v#{v}-custom/sd-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "8351212e40ae367519d3d709cdd81105c1a14c692091fe315bd69844f8aa4427"
      else
        url "https://github.com/waltarix/sd/releases/download/v#{v}-custom/sd-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "9f89b87bc59b48cc647338395760e339380f7b463ba9ddfabf139f84ed573c62"
      end
    end
  end
  license "MIT"

  def install
    bin.install "sd"
    man1.install "gen/sd.1"
    bash_completion.install "gen/completions/sd.bash" => "sd"
    fish_completion.install "gen/completions/sd.fish"
    zsh_completion.install "gen/completions/_sd"
  end

  test do
    assert_equal "after", pipe_output("#{bin}/sd before after", "before")
  end
end
