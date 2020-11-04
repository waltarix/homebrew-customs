class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.24.2.tar.gz"
  sha256 "8a07554bade6b3064531689d4da829accc843e28ea1ae3229d3bd6d2ebe4a84e"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.24.2-custom/fzf-0.24.2-linux_amd64.tar.xz"
      sha256 "dbe15aaa78c5911ab07d747d3177279f440b807f168912f1db3f5f41f5f63166"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.24.2-custom/fzf-0.24.2-darwin_amd64.tar.xz"
      sha256 "6fb1980e03a6f4254dd8053e2d41a3fe4b7116adaf7250a10b3b7d41b1693e7d"
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
