class Helix < Formula
  desc "Post-modern modal text editor"
  homepage "https://helix-editor.com"
  if OS.linux?
    url "https://github.com/waltarix/helix/releases/download/22.08.1-custom/helix-22.08.1-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "e8162e8121b2d162e942f70992d92863c37736e07026bd22e6f572def98f4846"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/helix/releases/download/22.08.1-custom/helix-22.08.1-aarch64-apple-darwin.tar.xz"
      sha256 "1a7af0f93a20b760448e4fbce1f17a7b123aeb64c0293c7885584b614b294f24"
    else
      url "https://github.com/waltarix/helix/releases/download/22.08.1-custom/helix-22.08.1-x86_64-apple-darwin.tar.xz"
      sha256 "6fa5c97dfd7463b9b08d11baf34b5cb4166b8c51b50e68c42c83f37dd1e16308"
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
