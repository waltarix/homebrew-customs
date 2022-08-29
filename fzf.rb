class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.33.0.tar.gz"
  sha256 "136ddddfdb229631b08ea7e67be965bcf9c95f5fe1360b80b11f81aa64ba19ad"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.33.0-custom/fzf-0.33.0-linux_amd64.tar.xz"
      sha256 "907418d37ce57e2f4bfdbc40dec165690487fbdc257c1eb6504c7557956c5cbc"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.33.0-custom/fzf-0.33.0-darwin_arm64.tar.xz"
        sha256 "924ee8c0f07d32eb8c43109963b0625697c9a51aebafed55412c533a2e15e5f2"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.33.0-custom/fzf-0.33.0-darwin_amd64.tar.xz"
        sha256 "f986ced589c85724ddf199f4d8406021913db0276bb76d4ffd44125ce2042bfe"
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
