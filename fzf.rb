class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.31.0.tar.gz"
  sha256 "df4edee32cb214018ed40160ced968d4cc3b63bba5b0571487011ee7099faa76"
  license "MIT"
  revision 2

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom-r2/fzf-0.31.0-linux_amd64.tar.xz"
      sha256 "5027dedb9a14a5701fd4d06268375ac50ce5e88a6a46dbebb86218c77b7eea95"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom-r2/fzf-0.31.0-darwin_arm64.tar.xz"
        sha256 "c14006fdf0a5641ab93bc7b29ae800d37645ad1533f36f16ea0288ef1ad4fff3"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.31.0-custom-r2/fzf-0.31.0-darwin_amd64.tar.xz"
        sha256 "ec6e975bf4bbdbee5a71a66deaf014c6a84fbed8d6f5111882e345dfd3712b0d"
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
