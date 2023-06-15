class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.42.0.tar.gz"
  sha256 "743c1bfc7851b0796ab73c6da7db09d915c2b54c0dd3e8611308985af8ed3df2"
  license "MIT"

  resource "binary" do
    "0.42.0".tap do |v|
      if OS.linux?
        url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-linux_amd64.tar.xz"
        sha256 "b44fb53dd911921f5133dcf7de8846b98d4fdf86df9283b6ebb699af6bce6376"
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "607239e1bf64cb020436b08724a3087cbb52f7b9ec94490ec68c879ad36835ea"
        else
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_amd64.tar.xz"
          sha256 "69aa802da0794f5b980e4c73fcbb534273ddd0fa3e1558c05aec4995d2c3d11f"
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
