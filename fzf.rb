class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.33.0.tar.gz"
  sha256 "136ddddfdb229631b08ea7e67be965bcf9c95f5fe1360b80b11f81aa64ba19ad"
  license "MIT"
  revision 1

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.33.0-custom-r1/fzf-0.33.0-linux_amd64.tar.xz"
      sha256 "24c43d74d1c0a8a8245b92d303f5eeff2b6e5fdb04d7756c265ab8d9140ed517"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.33.0-custom-r1/fzf-0.33.0-darwin_arm64.tar.xz"
        sha256 "b635dbb1c0b85e5071520613fdcc99bc5ce4582a52f8210ad75a5710fbe63a4b"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.33.0-custom-r1/fzf-0.33.0-darwin_amd64.tar.xz"
        sha256 "73fc4597f1772fea4abe1d8c45c2ea3ca29a331eec7469fbae0f9d116940a1d6"
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
