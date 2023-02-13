class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.37.0.tar.gz"
  sha256 "0044809beda82ba1a6936d5472cb749eef34785e8ecd4694936e39bf0ca9258b"
  license "MIT"

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.37.0-custom/fzf-0.37.0-linux_amd64.tar.xz"
      sha256 "ce98b373495f87e3729cd8a2343958b19343c63dcbbaed2f9a86bae136f54828"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.37.0-custom/fzf-0.37.0-darwin_arm64.tar.xz"
        sha256 "66a7771b4fb05459e651523c57c7c8ebdffa67d8ee0748a78e96995d538e94b2"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.37.0-custom/fzf-0.37.0-darwin_amd64.tar.xz"
        sha256 "c8ee9b28f8d95a3953b13718402b40b301d1a136cc16f40fbc407cdec1c6e796"
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
