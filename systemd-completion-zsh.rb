class SystemdCompletionZsh < Formula
  desc "System and service manager"
  homepage "https://wiki.freedesktop.org/www/Software/systemd/"
  url "https://github.com/systemd/systemd/archive/v251.tar.gz"
  sha256 "0ecc8bb28d3062c8e58a64699a9b16534554bb6a01efb8d5507c893db39f8d51"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  def install
    zsh_completion.install Dir["shell-completion/zsh/_*"].reject { |f| f.end_with?('.in') }
  end

  test do
    assert_match "_journalctl is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _journalctl'")
  end
end
