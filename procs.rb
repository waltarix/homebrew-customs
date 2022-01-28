class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.12.1-custom/procs-0.12.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "2fe6509024a98c6e21fad2e1bee88946f0770f0a26a8b3e097d91a7d792b5d72"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.12.1-custom/procs-0.12.1-aarch64-apple-darwin.tar.xz"
      sha256 "ec055dbfc2ea7d419a211e956d1e7718f4a44ad2b372e7454f9eca360f5d8774"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.12.1-custom/procs-0.12.1-x86_64-apple-darwin.tar.xz"
      sha256 "c7dd5fcc4d4940a4d00b31ebf18014bbd83c59f89e9af6c7b2f25af83be33f8a"
    end
  end
  license "MIT"

  def install
    bin.install "procs"

    system bin/"procs", "--completion", "bash"
    system bin/"procs", "--completion", "fish"
    system bin/"procs", "--completion", "zsh"
    bash_completion.install "procs.bash" => "procs"
    fish_completion.install "procs.fish"
    zsh_completion.install "_procs"
  end

  test do
    output = shell_output(bin/"procs")
    count = output.lines.count
    assert count > 2
    assert output.start_with?(" PID:")
  end
end
