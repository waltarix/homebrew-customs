class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/refs/tags/v0.64.0.tar.gz"
  sha256 "e990529375a75e9be03b58b6a136573b9fd1189c1223aaa760e47fcb94812172"
  license "MIT"

  resource "binary" do
    "0.64.0".tap do |v|
      if OS.linux?
        if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v2.tar.xz"
          sha256 "d1266e0a991a72b1250d1d3ec870372f921c58a7bacd6fc822845720a58405c0"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v4.tar.xz"
          sha256 "170b80f8015d77495754043bb5069a454cd0be104a9cfd5a026fc98bcb7b966b"
        end
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "538ed47278fa7b1ffe22aa1e78aa8abd0350d5aea98b9e458981cce88eeabde6"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_amd64_v3.tar.xz"
          sha256 "9bcbd24ca7627f25c38b07d0868afd2d89755a12be377addda08b22e3e06660d"
        end
      end
    end
  end

  def install
    resource("binary").stage do
      bin.install ["fzf", "bin/fzf-tmux"]
      (prefix/"plugin").install "plugin/fzf.vim"
    end

    # Please don't install these into standard locations (e.g. `zsh_completion`, etc.)
    # See: https://github.com/Homebrew/homebrew-core/pull/137432
    #      https://github.com/Homebrew/legacy-homebrew/pull/27348
    #      https://github.com/Homebrew/homebrew-core/pull/70543
    prefix.install "install", "uninstall"
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
    bin.install "bin/fzf-preview.sh"
  end

  def caveats
    <<~EOS
      To set up shell integration, see:
        https://github.com/junegunn/fzf#setting-up-shell-integration
      To use fzf in Vim, add the following line to your .vimrc:
        set rtp+=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"list").write %w[hello world].join($INPUT_RECORD_SEPARATOR)
    assert_equal "world", pipe_output("#{bin}/fzf -f wld", (testpath/"list").read).chomp
  end
end
