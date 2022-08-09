class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.32.1.tar.gz"
  sha256 "c7afef61553b3b3e4e02819c5d560fa4acf33ecb39829aeba392c2e05457ca6a"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.32.1-custom/fzf-0.32.1-linux_amd64.tar.xz"
      sha256 "b30605c33368d4f66de8e0057acbf7b23cc9c2a8ef28dd4554f4e90081534dca"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.32.1-custom/fzf-0.32.1-darwin_arm64.tar.xz"
        sha256 "81e293b3e7b06e07e38906403a063211cb6b7b6a1ede83554c35c5f4af8368b5"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.32.1-custom/fzf-0.32.1-darwin_amd64.tar.xz"
        sha256 "68c8cea4898f98672ec5d83134d6d0450e7c21b6f6463b3c06159a76ee9fb034"
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
