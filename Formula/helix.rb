class Helix < Formula
  desc "Post-modern modal text editor"
  homepage "https://helix-editor.com"
  "23.05".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "9ee3d44c9bc8b7d057ba593d4c06c46451a774aea9169fe81d9fb583237e6d3a"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "778d0d08f90da9e40b7c5c6de48fcd33d22347efdc91cb06fe7813610bab77fc"
      else
        url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "b25f5ea6983a80d1b069e37ac89cd09e1c18d651f54434b5713e1aafdb1dcbbc"
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
