class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/refs/tags/v0.66.0.tar.gz"
  sha256 "576659beee244b4ecccf45f1c576340143d8ce6d97fa053e6cbdd3f75c66b351"
  license "MIT"

  resource "binary" do
    "0.66.0".tap do |v|
      if OS.linux?
        if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v2.tar.xz"
          sha256 "c9bada1908465cea52cd89f4181e2d51a524b24f4a79a9cc39494b20cff33d5a"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v4.tar.xz"
          sha256 "a560128a97a3866f8d11829eb9f5735fab826ef41559beb966f208e33de2632b"
        end
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "fb7da20281118617e6bb432b901129bd39c0881557124505ce34db77a338442c"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_amd64_v3.tar.xz"
          sha256 "55fe2709bc605faf377fd4d97b5e3aa7339438f2d624e41d168774e2b252700d"
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
