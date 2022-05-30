class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.30.0.tar.gz"
  sha256 "a3428f510b7136e39104a002f19b2e563090496cb5205fa2e4c5967d34a20124"
  license "MIT"
  revision 1

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.30.0-custom-r1/fzf-0.30.0-linux_amd64.tar.xz"
      sha256 "cd966ae685425850817d4226db8bac2d4036531d2f52366757c4d23aacb4b6f1"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.30.0-custom-r1/fzf-0.30.0-darwin_arm64.tar.xz"
        sha256 "3ed7751e2070288a1e385f53147e04f016bab3e4dc37e7d158e7a5175d0bfda4"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.30.0-custom-r1/fzf-0.30.0-darwin_amd64.tar.xz"
        sha256 "a3d350eb6492e23db12bece85af5c63b41b419d5853b89e245ff3189da7842dc"
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
