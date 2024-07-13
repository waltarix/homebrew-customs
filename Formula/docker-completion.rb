class DockerCompletion < Formula
  desc "Bash, Zsh and Fish completion for Docker"
  homepage "https://www.docker.com/"
  "27.0.3".tap do |v|
    if OS.linux?
      url "https://download.docker.com/linux/static/stable/x86_64/docker-#{v}.tgz"
      sha256 "f6299aeada422d527cba35061fe56df5e2294776f6d39b7830d699335054b1e6"
    else
      if Hardware::CPU.arm?
        url "https://download.docker.com/mac/static/stable/aarch64/docker-#{v}.tgz"
        sha256 "aba1715305ef34ba5e96c5bda492872dc477b07ddef8c3e4f891ffefa96c1527"
      else
        url "https://download.docker.com/mac/static/stable/x86_64/docker-#{v}.tgz"
        sha256 "54e806f40e2a74e31aa808d568155496e365d8e65520386d98d2d570d2424e3f"
      end
    end
  end
  license "Apache-2.0"

  livecheck do
    formula "docker"
  end

  def install
    generate_completions_from_executable(buildpath/"docker", "completion", base_name: "docker")
  end

  test do
    assert_match "-F _docker",
      shell_output("bash -c 'source #{bash_completion}/docker && complete -p docker'")
  end
end
