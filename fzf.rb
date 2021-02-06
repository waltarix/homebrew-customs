class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.25.1.tar.gz"
  sha256 "b97cf9ab528391a49dfa45b459c767fb2626ade9f3a3f99d0108d7274f2eca8b"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"
  revision 1

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.25.1-custom-r1/fzf-0.25.1-linux_amd64.tar.xz"
      sha256 "5893c9e235f988a7c453488299f52a53ff5ef769e61d3e2cf096aaa7474bdb51"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.25.1-custom-r1/fzf-0.25.1-darwin_arm64.tar.xz"
        sha256 "c382dcdd4acbc82aa08f590b3044890ac01cda1dd2d7a1989ebfd5606e1d65c2"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.25.1-custom-r1/fzf-0.25.1-darwin_amd64.tar.xz"
        sha256 "98e0140cf36d982898995132dfbb01a9a858a673dd21d934a296bdc6697d6f05"
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
