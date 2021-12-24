class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.29.0.tar.gz"
  sha256 "a287a8806ce56d764100c5a6551721e16649fd98325f6bf112e96fb09fe3031b"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.29.0-custom/fzf-0.29.0-linux_amd64.tar.xz"
      sha256 "f9f95f50f7297aecd3c47928d57bbedbb35512a1d62611d85dd20e8b1567ea88"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.29.0-custom/fzf-0.29.0-darwin_arm64.tar.xz"
        sha256 "759551380916bb9b666fa52a06487eb98c5cb98131bafd0ca5dfffab1e332545"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.29.0-custom/fzf-0.29.0-darwin_amd64.tar.xz"
        sha256 "3e92d5ab92d0c85eafeb02f5a7e0014fa0ac4c5af13311448fc164efe227669a"
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
