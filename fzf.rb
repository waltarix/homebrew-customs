class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.21.1.tar.gz"
  sha256 "47adf138f17c45d390af81958bdff6f92157d41e2c4cb13773df078b905cdaf4"
  revision 3
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.21.1-custom/fzf-0.21.1-linux_amd64.tar.xz"
      sha256 "e84fd3aad18175ae03a724168bb4d51456c2128e3df518a22e19f461ebf58601"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.21.1-custom/fzf-0.21.1-darwin_amd64.tar.xz"
      sha256 "87f2b4ed1db8869ef09641b7adcf981c7ce0579dee56f7e79bca619a8726908d"
    end
  end

  def install
    bin.install resource("binary").files("fzf")

    prefix.install "install", "uninstall"
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    (prefix/"plugin").install "plugin/fzf.vim"
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
    bin.install "bin/fzf-tmux"
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
