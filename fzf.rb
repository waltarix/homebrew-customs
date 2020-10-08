class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.23.0.tar.gz"
  sha256 "f0f840183ee0c6a77e8d8e61352d94797f371940934d312df0186cb3248f789f"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.23.0-custom/fzf-0.23.0-linux_amd64.tar.xz"
      sha256 "d5a8b1be9835bad915f5d8cb7a657627d7622bf8603575634e07227755fd9e75"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.23.0-custom/fzf-0.23.0-darwin_amd64.tar.xz"
      sha256 "3e038f741348ba0a514cfc1cd6fa3444a5d82c52136cdb167099f5cf590425a2"
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
