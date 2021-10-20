class SystemdCompletionZsh < Formula
  desc "System and service manager"
  homepage "https://wiki.freedesktop.org/www/Software/systemd/"
  url "https://github.com/systemd/systemd/archive/v246.tar.gz"
  sha256 "4268bd88037806c61c5cd1c78d869f7f20bf7e7368c63916d47b5d1c3411bd6f"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  def install
    zsh_completion.install Dir["shell-completion/zsh/_*"]
  end

  test do
    assert_match "_journalctl is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _journalctl'")
  end
end
