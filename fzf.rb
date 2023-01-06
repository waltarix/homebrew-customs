class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.35.1.tar.gz"
  sha256 "d59ec6f2b6e95dad53bb81f758471e066c657be1b696f2fe569e1a9265dda8fe"
  license "MIT"
  revision 1

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.35.1-custom-r1/fzf-0.35.1-linux_amd64.tar.xz"
      sha256 "49aded01836e5f601b70e141a452b65b3b0187bdf8481ac70e5db3a8c3f21c86"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.35.1-custom-r1/fzf-0.35.1-darwin_arm64.tar.xz"
        sha256 "59fa309fd2d772919a001a7401a8fb9868184bf43795fbefc652d52a5214a864"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.35.1-custom-r1/fzf-0.35.1-darwin_amd64.tar.xz"
        sha256 "7475cf66eac47a3ece1c2ad99255e64b206528354545750a622c879fc4fbfddb"
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
