class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.43.0.tar.gz"
  sha256 "2cd3fd1f0bcba6bdeddbbbccfb72b1a8bdcbb8283d86600819993cc5e62b0080"
  license "MIT"

  resource "binary" do
    "0.43.0".tap do |v|
      if OS.linux?
        url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-linux_amd64.tar.xz"
        sha256 "39ce461a06a8ccf3dfe468df29aedbf947e471ae1a356682e95e9c1541785497"
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "fcd3b7e061e9ac75385769c021c4e17ad390050da22ed03893fb617b7f555bb1"
        else
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_amd64.tar.xz"
          sha256 "e547d9d60d6bc632f0ccf8539eb6db7c895775911c72820d4e30cf98ddba48d3"
        end
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
