class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.40.0.tar.gz"
  sha256 "9597f297a6811d300f619fff5aadab8003adbcc1566199a43886d2ea09109a65"
  license "MIT"

  resource "binary" do
    "0.40.0".tap do |v|
      if OS.linux?
        url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-linux_amd64.tar.xz"
        sha256 "6bc44fa9906192f6f52c2ac8391e287f8c6436f04aaf36d3b37f8977e7662544"
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "ae7a5bf7cac0a5fbb34986319b8b870e2bdf74f051f71ff53cdeac59ef800651"
        else
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_amd64.tar.xz"
          sha256 "598aa71a6ecb1f46191d6d18d73d42575abb275e802942ca7bccbd1ef4932b7f"
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
