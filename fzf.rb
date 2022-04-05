class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.30.0.tar.gz"
  sha256 "a3428f510b7136e39104a002f19b2e563090496cb5205fa2e4c5967d34a20124"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.30.0-custom/fzf-0.30.0-linux_amd64.tar.xz"
      sha256 "9c4e12a75d76ab1c2a4b3557f6939023713b6ff7a84cf142a9cbcbdfec34f4dc"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.30.0-custom/fzf-0.30.0-darwin_arm64.tar.xz"
        sha256 "898ce15f63c7ba900d52b1b38a532bf68132426fd6e69433f537e1e258ff9b01"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.30.0-custom/fzf-0.30.0-darwin_amd64.tar.xz"
        sha256 "459162a20e3a9d05acc66cbd8d47345a0260e878950c3849a44f74fe31b8d2e5"
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
