class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.34.0.tar.gz"
  sha256 "5bfd2518f0d136a76137de799ff5911608802d23564fc26e245f25a627395ecc"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.34.0-custom/fzf-0.34.0-linux_amd64.tar.xz"
      sha256 "386ca76a551cbdc510f46054d776f809cca5b28e6a4ff618c40fe973a9306de4"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.34.0-custom/fzf-0.34.0-darwin_arm64.tar.xz"
        sha256 "5a5f35d6afa4fff441743386a4167dcae5e56208c853ad4f751915ae81e96312"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.34.0-custom/fzf-0.34.0-darwin_amd64.tar.xz"
        sha256 "d64f441eb87ffb9b1813b3463ac145dbcf641c83f736aca65c6ce451e4b3249b"
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
