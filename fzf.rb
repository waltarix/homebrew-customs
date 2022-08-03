class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.32.0.tar.gz"
  sha256 "3502c15faeb0a6d553c68ab1a7f472af08afed94a1d016427a8ab053ef149a8f"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.32.0-custom/fzf-0.32.0-linux_amd64.tar.xz"
      sha256 "4fe0ff73d898ff7b21633c32c50b779b386f52ef4ef3b4393ee744c39177c186"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.32.0-custom/fzf-0.32.0-darwin_arm64.tar.xz"
        sha256 "c13d2e2faef59c6785532bf74468c1a2bac22141f5959a783bd8c511010585b7"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.32.0-custom/fzf-0.32.0-darwin_amd64.tar.xz"
        sha256 "897b98517fd8fd4cb8149cad00a8bba30ea0c97e5b7813c671f3913e7871dc34"
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
