class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.44.1.tar.gz"
  sha256 "295f3aec9519f0cf2dce67a14e94d8a743d82c19520e5671f39c71c9ea04f90c"
  license "MIT"

  resource "binary" do
    "0.44.1".tap do |v|
      if OS.linux?
        url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-linux_amd64.tar.xz"
        sha256 "cf3c6254b40f181604992c6b7f9f21bb28f61b6bdfcdbdb45534c54affc1e985"
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "c16d9bdcc0781222b64b0249e4e430fc6e80110d1bdd9791b655f3c6c4163fe9"
        else
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_amd64.tar.xz"
          sha256 "ea1c7f013f76ebbba6378bf89ebfc67fabead165e77508f4662c30048c703fe9"
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
