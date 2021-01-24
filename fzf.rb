class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.25.0.tar.gz"
  sha256 "ccbe13733d692dbc4f0e4c0d40c053cba8d22f309955803692569fb129e42eb0"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.25.0-custom-r1/fzf-0.25.0-linux_amd64.tar.xz"
      sha256 "c3fea60a740d352818eef0c253a1566759872b251c93ce75a9b0dd462f6429dc"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.25.0-custom-r1/fzf-0.25.0-darwin_arm64.tar.xz"
        sha256 "e4af3996afe0b4d6a4996004e329e72436da721449f7d9344b6107067e18c3e2"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.25.0-custom-r1/fzf-0.25.0-darwin_amd64.tar.xz"
        sha256 "abdf9fca5b1394280360963fc2958e1e47a349d17e910070944ca1c20b44d24c"
      end
    end
  end

  def install
    resource("binary").stage do
      bin.install ["bin/fzf", "bin/fzf-tmux"]
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
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end
