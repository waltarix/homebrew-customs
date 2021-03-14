class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.26.0.tar.gz"
  sha256 "a8dc01f16b3bf453fdc9e9a2cd0ca39db7a1b44386517bb7859805b053aa7810"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.26.0-custom/fzf-0.26.0-linux_amd64.tar.xz"
      sha256 "55dbf5537437432f5989d3e311a9938b07f247131de151b4141bceceea7b1641"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.26.0-custom/fzf-0.26.0-darwin_arm64.tar.xz"
        sha256 "9ce0023add62c0b5be56a4e44462eda917cacd9dca1c8ebf6086c5b06df668dd"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.26.0-custom/fzf-0.26.0-darwin_amd64.tar.xz"
        sha256 "643e52e3e6fc0814bd6af9f899ba32aa13eb7706875f561bae4d8adb6eb03f2f"
      end
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
