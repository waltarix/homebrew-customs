class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.35.0.tar.gz"
  sha256 "645cf0e1521d5c518f99acdca841a8113a2f0f5d785cb4147b92fcfa257a1ad0"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.35.0-custom/fzf-0.35.0-linux_amd64.tar.xz"
      sha256 "b612229f22febf5b56c0ffd54204fd3637c1744691bc5aa707127afad1b77d89"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.35.0-custom/fzf-0.35.0-darwin_arm64.tar.xz"
        sha256 "71d08af785ec5726228c026487ee53d8a66342850f86ea6674c6a2be82aa354c"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.35.0-custom/fzf-0.35.0-darwin_amd64.tar.xz"
        sha256 "5298f69bba3644333550d67556da1cbd6e3d3f7bf93752f554d6f3866a8237c5"
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
