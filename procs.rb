class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.11-custom/procs-0.11.11-x86_64-unknown-linux-musl.tar.xz"
    sha256 "958c029e7a6a195748fedbde8c256a917befbbea75fd8aa8626c0faad9af1ee1"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.11-custom/procs-0.11.11-aarch64-apple-darwin.tar.xz"
      sha256 "871835dc80a5d7d863785712174a54a29f9fb415b479d846fc2049ddefede2dc"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.11-custom/procs-0.11.11-x86_64-apple-darwin.tar.xz"
      sha256 "2bd2740ef915b3a42f6cebd8d539a1f821f3b6bfc3118c750529b1ee2ca5fa16"
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
