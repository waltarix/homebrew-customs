class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.27.0.tar.gz"
  sha256 "265c569f3b0c3c210b45831b80d4fba260c5956f3ebf88d2c5c8f9f6d759e388"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.27.0-custom/fzf-0.27.0-linux_amd64.tar.xz"
      sha256 "d20bd30559ec9a1cc987b0522c7f56b04875b6e22eca55b7f2566a65f7e2dcec"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.27.0-custom/fzf-0.27.0-darwin_arm64.tar.xz"
        sha256 "7b5cdaea67cbf3e84b7824f2bf52de2a5afccc588784a2df11f0fc9cc2af304a"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.27.0-custom/fzf-0.27.0-darwin_amd64.tar.xz"
        sha256 "01919f0b9f0c00f9962a1e51723c61ba97bd2d8f4dc8d0c92c0cda4e9eaae022"
      end
    end
  end

  def install
    resource("binary").stage do
      bin.install ["bin/fzf", "bin/fzf-tmux"]
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
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end
