class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.24.1.tar.gz"
  sha256 "35e8f57319d4b0ad3297251f4487b15203d288a081c1019d67f80758264b9d45"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.24.1-custom/fzf-0.24.1-linux_amd64.tar.xz"
      sha256 "4236eba7d6d0e6954ccb0da72715bef0dd521abf168bd350fb89213359eac06e"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.24.1-custom/fzf-0.24.1-darwin_amd64.tar.xz"
      sha256 "dee2adae7fb36ed2bb539e5e4a33a7ed29cd7a615b721c503a7bc121a7c8eac9"
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
