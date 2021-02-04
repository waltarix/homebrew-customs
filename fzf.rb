class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.25.1.tar.gz"
  sha256 "b97cf9ab528391a49dfa45b459c767fb2626ade9f3a3f99d0108d7274f2eca8b"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.25.1-custom/fzf-0.25.1-linux_amd64.tar.xz"
      sha256 "8be293adaa7c14c50263c8ebd267f58d7a4680d2a79e3227c724ab82e4090ef7"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.25.1-custom/fzf-0.25.1-darwin_arm64.tar.xz"
        sha256 "4d3e268c2ff86446d7039ac0786fc397664e583889fcd5883c68f9a962de619b"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.25.1-custom/fzf-0.25.1-darwin_amd64.tar.xz"
        sha256 "20ba112635823d41accd13f184ce7b886136833c5f16f373a9a316a5f2755a6f"
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
