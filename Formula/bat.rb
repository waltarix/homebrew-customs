class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  "0.24.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/bat/releases/download/v#{v}-custom/bat-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "94b1ac0cdd5103db86d2b978efe935bab6421d4688561dadd7b9787c331910c4"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom/bat-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "2e8583da49931af37e34ad42563defe74ad6bc66d75919d380fdbe723005b5c2"
      else
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom/bat-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "4e5962637a815559c9f1085f4a2dd9487f0fc0a9f4f207f841340412ca702edb"
      end
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
