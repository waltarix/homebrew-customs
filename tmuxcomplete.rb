class Tmuxcomplete < Formula
  desc "Completion of words in adjacent tmux panes"
  homepage "https://github.com/wellle/tmux-complete.vim"
  url "https://raw.githubusercontent.com/waltarix/tmux-complete.vim/custom/sh/tmuxcomplete"
  sha256 "8f40b2ce60e0b96d28413eebc1fac72ad6733309fe302f5e063a4cba0a23895d"
  version "0.1.4"
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
