class SystemdCompletion < Formula
  desc "System and service manager"
  homepage "https://wiki.freedesktop.org/www/Software/systemd/"
  url "https://github.com/systemd/systemd-stable/archive/refs/tags/v254.5.tar.gz"
  sha256 "41873783aa1c680e10d2f2626797a1c2fef8018d69b68c8c77639e140ee7846d"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]
  head "https://github.com/systemd/systemd.git", branch: "main"

  depends_on "jinja2-cli" => :build

  def install
    (buildpath/"template_variables.json").write({
      ROOTLIBEXECDIR: "/lib/systemd"
    }.to_json)

    func = ->(completion, target) do
      case target
      when %r{/meson.build\z}
        return
      when /\.in\z/
        completion_file = File.basename(target, ".in")
        system "jinja2", "-o", completion_file, target, "template_variables.json"
        completion.install completion_file
      else
        completion.install target
      end
    end

    Dir["shell-completion/zsh/*"].each(&func.curry.call(zsh_completion))
    Dir["shell-completion/bash/*"].each(&func.curry.call(bash_completion))
  end

  test do
    assert_match "_journalctl is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _journalctl'")

    assert_match "-F _journalctl",
      shell_output("bash -c 'source #{bash_completion}/journalctl && complete -p journalctl'")
  end
end
