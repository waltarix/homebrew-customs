class SystemdCompletionZsh < Formula
  desc "System and service manager"
  homepage "https://wiki.freedesktop.org/www/Software/systemd/"
  url "https://github.com/systemd/systemd/archive/v245.tar.gz"
  sha256 "f34f1dc52b2dc60563c2deb6db86d78f6a97bceb29aa0511436844b2fc618040"
  license "LGPL-2.0"

  bottle :unneeded

  def install
    zsh_completion.install Dir["shell-completion/zsh/_*"]
  end

  test do
    assert_match "_journalctl is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _journalctl'")
  end
end
