class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.24.4.tar.gz"
  sha256 "0d9d3ed3cefee86accc2634fc98211af1d571845d912256c33ca0c8b2963d8bd"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.24.4-custom/fzf-0.24.4-linux_amd64.tar.xz"
      sha256 "4b31b6e45f01460f9ab81237be3e41cf43ef0917bcd51e261a86e5fa453ed8bd"
    else
      url "https://github.com/waltarix/fzf/releases/download/0.24.4-custom/fzf-0.24.4-darwin_amd64.tar.xz"
      sha256 "8968f03a7e3d5ad8ca1259da166c21c25737783aba24d7d4b10437a3b3e51e22"
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
