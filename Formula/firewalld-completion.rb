class FirewalldCompletion < Formula
  desc "Stateful zoning firewall daemon with D-Bus interface"
  homepage "https://firewalld.org/"
  url "https://github.com/firewalld/firewalld/releases/download/v1.3.0/firewalld-1.3.0.tar.gz"
  sha256 "a0f2ae3d42c7a10646c5309d3c6faab955f640c4c5484885c8c7968e0c260ed9"
  license "GPL-2.0-or-later"

  def install
    zsh_completion.install "shell-completion/zsh/_firewalld"
    bash_completion.install "shell-completion/bash/firewall-cmd"
  end

  test do
    assert_match "_firewalld is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _firewalld'")

    assert_match "-F _firewall_cmd",
      shell_output("bash -c 'source #{bash_completion}/firewall-cmd && complete -p firewall-cmd'")
  end
end
