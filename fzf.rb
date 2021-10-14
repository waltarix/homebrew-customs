class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.27.2.tar.gz"
  sha256 "7798a9e22fc363801131456dc21026ccb0f037aed026d17df60b1178b3f24111"
  license "MIT"
  revision 1
  head "https://github.com/junegunn/fzf.git"

  bottle :unneeded

  resource "binary" do
    if OS.linux?
      url "https://github.com/waltarix/fzf/releases/download/0.27.2-custom-r3/fzf-0.27.2-linux_amd64.tar.xz"
      sha256 "991858baf6591fb579a1d2f32d64b8f9f2583dc5a2da89e521dbb00e75000820"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/fzf/releases/download/0.27.2-custom-r3/fzf-0.27.2-darwin_arm64.tar.xz"
        sha256 "d59a9fce44ed4b36128c60f091cf2409e187f2edf88657e5bdba0014d8d98c60"
      else
        url "https://github.com/waltarix/fzf/releases/download/0.27.2-custom-r3/fzf-0.27.2-darwin_amd64.tar.xz"
        sha256 "d5cb9e8169597900eacb35c2986ed124d3157a6425593bfc130ee69c1c8903b3"
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
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end
