class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.24.3.tar.gz"
  sha256 "5643a21851b7f495cd33d42839f46f0e975b162aa7aa5f2079f8c25764be112a"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.24.3-custom/fzf-0.24.3-linux_amd64.tar.xz"
      sha256 "8c797e3b8b2d3f3e81e6537de2b03ebe3fad2c0fbdc247a38abd468916f17185"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.24.3-custom/fzf-0.24.3-darwin_amd64.tar.xz"
      sha256 "85c24b57a9e1771e7caf6e1c918b48b6ade361ab8f3e13b5a076fbf6285cd64e"
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
