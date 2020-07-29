class Tmuxcomplete < Formula
  desc "Completion of words in adjacent tmux panes"
  homepage "https://github.com/wellle/tmux-complete.vim"
  url "https://raw.githubusercontent.com/wellle/tmux-complete.vim/v0.1.4/sh/tmuxcomplete"
  sha256 "1406e7a695680ad72aa9f250b34cedf2a1662737e9ab3627333b7dd9143afc92"
  license "MIT"

  bottle :unneeded

  def install
    bin.install "tmux-complete.vim" => "tmuxcomplete"
  end

  test do
    ENV["PATH"] = ""
    output = shell_output("#{bin}/tmuxcomplete")
    assert_match "No tmux found!", output
  end
end
