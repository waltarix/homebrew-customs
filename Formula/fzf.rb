class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/refs/tags/v0.54.0.tar.gz"
  sha256 "ce658b153254e25cf4244365d639cf3ac5b91230a20f76bd6845d88e1267a2db"
  license "MIT"

  resource "binary" do
    "0.54.0".tap do |v|
      if OS.linux?
        if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v2.tar.xz"
          sha256 "b4a3e6c0081d265e977a17113c4cba81f447eb216978f405e2ae3544288500ac"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v4.tar.xz"
          sha256 "fb3e1d402aface49039ec1aa3821ba2ac112bdbf1a505fd7c759040992ad7c26"
        end
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "e4d2caf10c66687f425c8e143491a509f6a48f52957fc1a22af9f1996d63643b"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_amd64_v3.tar.xz"
          sha256 "33d2e645d4fae0bee32b09b2af18672c30f6b2657bb883d9e0e6934b43203196"
        end
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
