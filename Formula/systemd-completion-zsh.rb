class SystemdCompletionZsh < Formula
  desc "System and service manager"
  homepage "https://wiki.freedesktop.org/www/Software/systemd/"
  url "https://github.com/systemd/systemd/archive/v252.tar.gz"
  sha256 "113a9342ddf89618a17c4056c2dd72c4b20b28af8da135786d7e9b4f1d18acfb"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  def install
    zsh_completion.install Dir["shell-completion/zsh/_*"].reject { |f| f.end_with?('.in') }
  end

  test do
    assert_match "_journalctl is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _journalctl'")
  end
end
