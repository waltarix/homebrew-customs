class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.35.1.tar.gz"
  sha256 "d59ec6f2b6e95dad53bb81f758471e066c657be1b696f2fe569e1a9265dda8fe"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.35.1-custom/fzf-0.35.1-linux_amd64.tar.xz"
      sha256 "f9862e98443c85485afb2e847538ca7d16e46dfbf310a4401e11e33dd4c299a4"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.35.1-custom/fzf-0.35.1-darwin_arm64.tar.xz"
        sha256 "788aeb8142dd2aa746aac14b28ba1e3e0958ed9a23f76f0503870abbe11ec417"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.35.1-custom/fzf-0.35.1-darwin_amd64.tar.xz"
        sha256 "a368d7aaaa516a39ba3b4585573a2b96f498d37f56c19a3d762b4a46dbdef162"
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
