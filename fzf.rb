class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.22.0.tar.gz"
  sha256 "3090748bb656333ed98490fe62133760e5da40ba4cd429a8142b4a0b69d05586"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.22.0-custom/fzf-0.22.0-linux_amd64.tar.xz"
      sha256 "a47b5e6c801668de257d519d9b4ede258d371b48d0bc707141338580cd8e2d7d"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.22.0-custom/fzf-0.22.0-darwin_amd64.tar.xz"
      sha256 "c78a27150b2d5b30af5b5a8fb0ccbf2621d56911a459efde6ee6387591670477"
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
