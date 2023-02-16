class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.38.0.tar.gz"
  sha256 "75ad1bdb2ba40d5b4da083883e65a2887d66bd2d4dbfa29424cb3f09c37efaa7"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.38.0-custom/fzf-0.38.0-linux_amd64.tar.xz"
      sha256 "4b0764ba2a1d9a265b193d524d25d6f3c821a06e181469e364d5808d11a200c0"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.38.0-custom/fzf-0.38.0-darwin_arm64.tar.xz"
        sha256 "f95210e1cc7406d55b09a893fc6851348322645fa62d8470f41196db89bf72ce"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.38.0-custom/fzf-0.38.0-darwin_amd64.tar.xz"
        sha256 "cc9273ec98e827464403d081f79a3fad38be0b44da7107560769375c65d6d6d9"
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
