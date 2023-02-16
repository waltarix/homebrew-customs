class SystemdCompletion < Formula
  desc "System and service manager"
  homepage "https://wiki.freedesktop.org/www/Software/systemd/"
  url "https://github.com/systemd/systemd/archive/v253.tar.gz"
  sha256 "acbd86d42ebc2b443722cb469ad215a140f504689c7a9133ecf91b235275a491"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  def install
    zsh_completion.install Dir["shell-completion/zsh/_*"].reject { |f| f.end_with?('.in') }
    bash_completion.install Dir["shell-completion/bash/*"].reject { |f| f.end_with?('.in') }
  end

  test do
    assert_match "_journalctl is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _journalctl'")

    assert_match "-F _journalctl",
      shell_output("bash -c 'source #{bash_completion}/journalctl && complete -p journalctl'")
  end
end
