class DockerCompletion < Formula
  desc "Bash, Zsh and Fish completion for Docker"
  homepage "https://www.docker.com/"
  "23.0.2".tap do |v|
    if OS.linux?
      url "https://download.docker.com/linux/static/stable/x86_64/docker-#{v}.tgz"
      sha256 "0f3a1f3b7cba049026e86b6b736da990726721ce91d82b88e1e11a170fd754b6"
    else
      if Hardware::CPU.arm?
        url "https://download.docker.com/mac/static/stable/aarch64/docker-#{v}.tgz"
        sha256 "a79d36a6d708b62f0509ed7b52b2f36d3f6ecde297f4d8a8fbd7997968e4b771"
      else
        url "https://download.docker.com/mac/static/stable/x86_64/docker-#{v}.tgz"
        sha256 "b59a4083d252c037a6488fe61704d05e8e25e8d136cedb17e4b1fd333138b278"
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
