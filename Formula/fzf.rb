class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.41.1.tar.gz"
  sha256 "982682eaac377c8a55ae8d7491fcd0e888d6c13915d01da9ebb6b7c434d7f4b5"
  license "MIT"

  resource "binary" do
    "0.41.1".tap do |v|
      if OS.linux?
        url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-linux_amd64.tar.xz"
        sha256 "9ce9ba05ee58447884ed4c58fc61153b5ea1386d8d3cc164b26f4cd9b3c4ab06"
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "51f66ddde63c5a45aa5c8f691536680ab18a0a9a907deda62d8d7b18a709dab3"
        else
          url "https://github.com/waltarix/fzf/releases/download/#{v}-custom/fzf-#{v}-darwin_amd64.tar.xz"
          sha256 "ffb737b509d5b23e317e295a2e9eb785667b4f4e6e4635983186c49a6eb0157c"
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
