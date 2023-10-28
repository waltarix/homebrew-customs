class DockerCompletion < Formula
  desc "Bash, Zsh and Fish completion for Docker"
  homepage "https://www.docker.com/"
  "24.0.7".tap do |v|
    if OS.linux?
      url "https://download.docker.com/linux/static/stable/x86_64/docker-#{v}.tgz"
      sha256 "984d59a77fa6acab97ea725a966facd33725e0e09c2fee975397fe1c6379bd3d"
    else
      if Hardware::CPU.arm?
        url "https://download.docker.com/mac/static/stable/aarch64/docker-#{v}.tgz"
        sha256 "e6923d42f0070feacaddaf640ff0ab20dacd893b2420c5d39ef0878f1ed302aa"
      else
        url "https://download.docker.com/mac/static/stable/x86_64/docker-#{v}.tgz"
        sha256 "2a791969cf6866b059046ec603ab3f1461651c9aabcce85b41be372d96a5faef"
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
