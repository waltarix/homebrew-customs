class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.28.0.tar.gz"
  sha256 "05bbfa4dd84b72e55afc3fe56c0fc185d6dd1fa1c4eef56a1559b68341f3d029"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.28.0-custom/fzf-0.28.0-linux_amd64.tar.xz"
      sha256 "941ea4e40e8861467d64ea0fc502124f9e8190120e291c630a60f82e83597f20"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.28.0-custom/fzf-0.28.0-darwin_arm64.tar.xz"
        sha256 "4caeff4fe205ed9641265ae683e8efd52c7de94d668ede5b96874d2f63812953"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.28.0-custom/fzf-0.28.0-darwin_amd64.tar.xz"
        sha256 "c242166ca3a8af5b66c10364cff822855a75c15b6f165a45ead5b07efc2bec46"
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
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end
