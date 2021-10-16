class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.27.3.tar.gz"
  sha256 "a0ad8dc6dd5c7a0c87ad623c0d9164cc2861489b76cb7a8b66f51cb4f9a81254"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.27.3-custom/fzf-0.27.3-linux_amd64.tar.xz"
      sha256 "6592426b2aaa0058738529832a43679e3764981e8a018946ee014320c0b4d761"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.27.3-custom/fzf-0.27.3-darwin_arm64.tar.xz"
        sha256 "2e4833e0ee3a784551f432c6509e6c1f6bf15747204f0cbb1b150133930101ba"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.27.3-custom/fzf-0.27.3-darwin_amd64.tar.xz"
        sha256 "1829fc515eccc8288fd6359b4f99a40f97552212290309fb3591ba39e1d82bad"
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
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end
