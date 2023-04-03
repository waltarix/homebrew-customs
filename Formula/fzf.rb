class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.39.0.tar.gz"
  sha256 "ac665ac269eca320ca9268227142f01b10ad5d25364ff274658b5a9f709a7259"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.39.0-custom/fzf-0.39.0-linux_amd64.tar.xz"
      sha256 "c94fedad270b5d97804ddec9f66b7d494eb2c6e791be112c44cadf4559f682b6"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.39.0-custom/fzf-0.39.0-darwin_arm64.tar.xz"
        sha256 "0f0695ad18b59b75a7d49cea9be5c278f140933fb8298d03508ab8bdd8b3b42a"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.39.0-custom/fzf-0.39.0-darwin_amd64.tar.xz"
        sha256 "c7f6a3079b238a628c11ec9d81008d5323186ffd430621b6a2aa4fccf23d14f2"
      end
    end
  end

  def install
    resource("binary").stage do
      bin.install ["fzf", "bin/fzf-tmux"]
      (prefix/"plugin").install "plugin/fzf.vim"
    end

    prefix.install "install", "uninstall"
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
  end

  def caveats
    <<~EOS
      To install useful keybindings and fuzzy completion:
        #{opt_prefix}/install

      To use fzf in Vim, add the following line to your .vimrc:
        set rtp+=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"list").write %w[hello world].join($INPUT_RECORD_SEPARATOR)
    assert_equal "world", pipe_output("#{bin}/fzf -f wld", (testpath/"list").read).chomp
  end
end
