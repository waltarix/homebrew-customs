class Helix < Formula
  desc "Post-modern modal text editor"
  homepage "https://helix-editor.com"
  "23.03".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "378753107c2bf16cc7890f44a95fece10e3e42cbb715a6a68f03e3ce361b8219"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "8bcaf4e92b39f58ece6b2c358c0174573333530ebddb74269172fb9b6d98d9c8"
      else
        url "https://github.com/waltarix/helix/releases/download/#{v}-custom/helix-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "da5f01fb0a089a45913d222282d9f692cb9b68b8e171bb0b10cf9e9bbbd055f7"
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
