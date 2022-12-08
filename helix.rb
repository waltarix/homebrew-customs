class Helix < Formula
  desc "Post-modern modal text editor"
  homepage "https://helix-editor.com"
  if OS.linux?
    url "https://github.com/waltarix/helix/releases/download/22.12-custom/helix-22.12-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "2b1764fd73bb890e43df3266579d1e0f540a932620469ec7fc7cf0f79511aa54"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/helix/releases/download/22.12-custom/helix-22.12-aarch64-apple-darwin.tar.xz"
      sha256 "cfebfc4909a6a81d7e0c47fcb44a13b89e72f5c7600dc35c405eb811bebcab0c"
    else
      url "https://github.com/waltarix/helix/releases/download/22.12-custom/helix-22.12-x86_64-apple-darwin.tar.xz"
      sha256 "fb64435440900e8743aa87dbd55b386721945035c1e1396045b7671f31f036ec"
    end
  end
  license "MPL-2.0"

  def install
    (libexec/"bin").install "hx"
    libexec.install "runtime"

    (bin/"hx").write_env_script(libexec/"bin/hx", HELIX_RUNTIME: libexec/"runtime")

    bash_completion.install "contrib/completion/hx.bash" => "hx"
    fish_completion.install "contrib/completion/hx.fish"
    zsh_completion.install "contrib/completion/hx.zsh" => "_hx"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hx -V")
    assert_match "✓", shell_output("#{bin}/hx --health")
  end
end
