class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.21.1.tar.gz"
  sha256 "47adf138f17c45d390af81958bdff6f92157d41e2c4cb13773df078b905cdaf4"
  head "https://github.com/junegunn/fzf.git"
  revision 1

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.21.1-custom/fzf-0.21.1-linux_amd64.tar.xz"
      sha256 "6609ea83eec7a952154bbf762d2979f32adfa0ae4cc8e823331d50c70c605153"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.21.1-custom/fzf-0.21.1-darwin_amd64.tar.xz"
      sha256 "16aa136d41b0e36ab7571dc2948545c2bbc839a33198fbb4cce9318dbb077234"
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
