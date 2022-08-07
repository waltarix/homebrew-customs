class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.32.0.tar.gz"
  sha256 "3502c15faeb0a6d553c68ab1a7f472af08afed94a1d016427a8ab053ef149a8f"
  license "MIT"
  revision 1

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.32.0-custom-r1/fzf-0.32.0-linux_amd64.tar.xz"
      sha256 "0ceeec694da27f88d2982cacb035f08d3889fc13c64d18e0e76575f7c856c104"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.32.0-custom-r1/fzf-0.32.0-darwin_arm64.tar.xz"
        sha256 "d3c3da099083d87561d4171470b4c42152b321000abea3344e354065ad527471"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.32.0-custom-r1/fzf-0.32.0-darwin_amd64.tar.xz"
        sha256 "83ee46131a537d45119ed0c4a3aa165a590c4008695a064abf05978640dd80ca"
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
