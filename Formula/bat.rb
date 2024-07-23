class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  ["0.24.0", 1].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "96913afb4e39cbfc4747c7f107d8676bc88d2601e581c56be0ba9cafd5216c9f"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "b713311d0e24c8d541a33f092abc78b2ceb268cd47c59371f41ed60fceb6c791"
      else
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "36ffc02ad55803f89ad94128d76688540d0421429a0a4b0be7a17af0a2fcb827"
      end
    end
    revision r if r
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
