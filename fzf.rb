class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.31.0.tar.gz"
  sha256 "df4edee32cb214018ed40160ced968d4cc3b63bba5b0571487011ee7099faa76"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom/fzf-0.31.0-linux_amd64.tar.xz"
      sha256 "c24b5f4144294bf43573ff021cf44fcfc5682abbccb1264183805d32663e6c44"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom/fzf-0.31.0-darwin_arm64.tar.xz"
        sha256 "a1d5f533c0106a7c742356bfd906b33a34913fa99a3765ecc1686fa6306308ba"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom/fzf-0.31.0-darwin_amd64.tar.xz"
        sha256 "9d74e20b854e8ecb102a8c8fa84526db958a3cf39ed7a6ab4df978cf0c5e3365"
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
