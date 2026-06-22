class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://junegunn.github.io/fzf/"
  url "https://github.com/junegunn/fzf/archive/refs/tags/v0.73.1.tar.gz"
  sha256 "ae4f49f8606a7d28498208fa1b93c5d3b890719eea97e02559e66160138b750c"
  license "MIT"

  resource "binary" do
    "0.73.1".tap do |v|
      if OS.linux?
        if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v2.tar.xz"
          sha256 "8fd09d8cea91302aa91512d0bbe68f97f2724b170734a698ea53553788f6f4aa"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-linux_amd64_v4.tar.xz"
          sha256 "ce080ad92a1f6107db77d68fe7f0dabd4877cba223df70cb0ca294a4d144f231"
        end
      else
        if Hardware::CPU.arm?
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_arm64.tar.xz"
          sha256 "1afeb38f91927199e14c76cf3f2c0c928572f9328604d9a70e139efbd06c1472"
        else
          url "https://github.com/waltarix/fzf/releases/download/v#{v}-custom/fzf-#{v}-darwin_amd64_v3.tar.xz"
          sha256 "04ffa0da7906f5ffbcf7a59645570ed0c38086890fa784e48b15246d09a4d511"
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
