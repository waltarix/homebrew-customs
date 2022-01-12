class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.29.0.tar.gz"
  sha256 "a287a8806ce56d764100c5a6551721e16649fd98325f6bf112e96fb09fe3031b"
  license "MIT"
  revision 1
  head "https://github.com/junegunn/fzf.git"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.29.0-custom-r1/fzf-0.29.0-linux_amd64.tar.xz"
      sha256 "0d31b2f66f640f70e01d626e745e4fd8fd25d75ffcce4e3cccb4638497f9f60d"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.29.0-custom-r1/fzf-0.29.0-darwin_arm64.tar.xz"
        sha256 "9cbd87162a898373aed443ed1ccd68a2b8f5beb7caa53d834a7bf1c99d90f8d7"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.29.0-custom-r1/fzf-0.29.0-darwin_amd64.tar.xz"
        sha256 "c07670c551fbf6958a19c14617b2fd45b90c7e52773bbcc8526a807aa8c14b7e"
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
    assert_equal "world", pipe_output("#{bin}/fzf -f wld", (testpath/"list").read).chomp
  end
end
