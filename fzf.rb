class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.31.0.tar.gz"
  sha256 "df4edee32cb214018ed40160ced968d4cc3b63bba5b0571487011ee7099faa76"
  license "MIT"
  revision 1

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom-r1/fzf-0.31.0-linux_amd64.tar.xz"
      sha256 "2ca2347b940a74636d630e9e138f73a69e468c7c89d62de7da507b810dcba7db"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom-r1/fzf-0.31.0-darwin_arm64.tar.xz"
        sha256 "b47f3771dcbbe1bd8e0fe6a0c1a33d972a28fb0844e1c1496263d66d56c9cfe8"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom-r1/fzf-0.31.0-darwin_amd64.tar.xz"
        sha256 "1632705ae6665320d67d4d4e6cc1b7a3671f3ad28e98f2028871c5e67738fc18"
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
