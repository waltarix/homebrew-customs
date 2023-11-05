class Helix < Formula
  desc "Post-modern modal text editor"
  homepage "https://helix-editor.com"
  "23.10".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "8531ff38fa8f4282a25c21966815fa4424306af7ef856d61161905a94a089096"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "b9efbd89ddd06f8e255eb482e1f06a823918590128b8d3e9530db4a89bdbd5e0"
      else
        url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "1bfd98275597e3a2d2b83ca4ac2d6996df8f582699d16562b88af9f090a7e401"
      end
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
