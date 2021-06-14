class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.27.2.tar.gz"
  sha256 "7798a9e22fc363801131456dc21026ccb0f037aed026d17df60b1178b3f24111"
  license "MIT"
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.27.2-custom/fzf-0.27.2-linux_amd64.tar.xz"
      sha256 "6cf1e32e8676d2baf29ca41cc133a3381013e9d989d5f133c4082ee9031beae4"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.27.2-custom/fzf-0.27.2-darwin_arm64.tar.xz"
        sha256 "f21060bf0622940d161954e1b0851aee0559e50a39e6ebf8f0fa8cc135aff918"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.27.2-custom/fzf-0.27.2-darwin_amd64.tar.xz"
        sha256 "eaf90eafb722f9ffb73c3b84e373b74c7c66ac1bc54f0427d0e1775b7bcaa780"
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
