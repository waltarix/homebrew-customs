class SystemdCompletionZsh < Formula
  desc "System and service manager"
  homepage "https://wiki.freedesktop.org/www/Software/systemd/"
  url "https://github.com/systemd/systemd/archive/v250.tar.gz"
  sha256 "389935dea020caf6e2e81a4e90e556bd5599a2086861045efdc06197776e94e1"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  def install
    zsh_completion.install Dir["shell-completion/zsh/_*"].reject { |f| f.end_with?('.in') }
  end

  test do
    assert_match "_journalctl is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _journalctl'")
  end
end
