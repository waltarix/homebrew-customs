class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/refs/tags/v0.67.0.tar.gz"
  sha256 "da72936dd23045346769dbf233a7a1fa6b4cfe4f0e856b279821598ce8f692af"
  license "MIT"

  resource "binary" do
    "0.67.0".tap do |v|
      if OS.linux?
        if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v2.tar.xz"
          sha256 "2f689e35f4fa5ee95ebdb474e85f09e6d676d0fa7dda74098f49ef3419f7d30f"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v4.tar.xz"
          sha256 "8bffba7daed5485cbb4f0476008b9c3c2b8036aea0b81f70e2789f549f0c51a2"
        end
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "b626560617e473de16b64f04e12429b57a8246857b9b0a2e0b8d48a86f7b6abd"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_amd64_v3.tar.xz"
          sha256 "7b08e890e95dbcd101f288afccfcb273f97f82f8b54e5b83c63978b600f9a5ae"
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
