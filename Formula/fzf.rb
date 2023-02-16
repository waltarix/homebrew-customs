class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.38.0.tar.gz"
  sha256 "75ad1bdb2ba40d5b4da083883e65a2887d66bd2d4dbfa29424cb3f09c37efaa7"
  license "MIT"
  revision 1

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.38.0-custom-r1/fzf-0.38.0-linux_amd64.tar.xz"
      sha256 "f0b33f617469144745fd95d421899f61723dec26ccdaafdad7ac1472214e9e44"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.38.0-custom-r1/fzf-0.38.0-darwin_arm64.tar.xz"
        sha256 "b2c980ba81ea8922efca4ac3fc88224ba7e53b9825ee6c2b1dacd0bea001afee"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.38.0-custom-r1/fzf-0.38.0-darwin_amd64.tar.xz"
        sha256 "4f84c4423ecd85ae153966c9e82820d8c0cd1a055ce232f69bebcd9765b94f13"
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
