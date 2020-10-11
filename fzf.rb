class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.23.1.tar.gz"
  sha256 "07576e47d2d446366eb7806fd9f825a2340cc3dc7f799f1f53fe038ca9bf30f6"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.23.1-custom/fzf-0.23.1-linux_amd64.tar.xz"
      sha256 "ac734d84350df418f587a616580af547ff1dced7cfd8e2fa04d0af506d222692"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.23.1-custom/fzf-0.23.1-darwin_amd64.tar.xz"
      sha256 "a236230f27d9d50c36984a154f2f7e287a704048578c7ddc91db603dabc2f26b"
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
