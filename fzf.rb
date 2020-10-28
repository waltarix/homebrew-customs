class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.24.0.tar.gz"
  sha256 "ce76f5f1a7cef05061e3cb2ab1eba7bc47660a868d622b5dd914e50158129ff6"
  license "MIT"
  revision 1
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.24.0-custom/fzf-0.24.0-linux_amd64.tar.xz"
      sha256 "7e79c88e2182dde4cbf92d1581fe333f7713f20ada690ce6a2b130f584594f7f"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.24.0-custom/fzf-0.24.0-darwin_amd64.tar.xz"
      sha256 "890d56869427f9c3778c5eeba0b5e6ba710577dfc44b215c540023657eac7ca8"
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
