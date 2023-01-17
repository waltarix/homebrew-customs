class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.36.0.tar.gz"
  sha256 "4745443ac751b7e322a61fbf7b0e4a8c3c1c47a482a7e9d3d31230faed8f4443"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.36.0-custom/fzf-0.36.0-linux_amd64.tar.xz"
      sha256 "ed90167a204d9518e7e6723bfbba0a2600a2c75742cd60779a00cff0764cfe1a"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.36.0-custom/fzf-0.36.0-darwin_arm64.tar.xz"
        sha256 "5add75c48ee0f958c8496c566e188f56d9c092433b9a051db98b94e920851a76"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.36.0-custom/fzf-0.36.0-darwin_amd64.tar.xz"
        sha256 "df807d7c76dd4eb8e2e2d304082c32d946a31f1e74283b49e234c6ac753b36e7"
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
