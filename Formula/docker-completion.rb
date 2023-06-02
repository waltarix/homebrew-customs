class DockerCompletion < Formula
  desc "Bash, Zsh and Fish completion for Docker"
  homepage "https://www.docker.com/"
  "24.0.2".tap do |v|
    if OS.linux?
      url "https://download.docker.com/linux/static/stable/x86_64/docker-#{v}.tgz"
      sha256 "fc07577bc0abdcdc02948493cd30b36cf0b096213fade9a7e699132c06c2e34c"
    else
      if Hardware::CPU.arm?
        url "https://download.docker.com/mac/static/stable/aarch64/docker-#{v}.tgz"
        sha256 "19cd208991b7bc46ad89042bd71580f4d9108e64b622105e863278cb3074152a"
      else
        url "https://download.docker.com/mac/static/stable/x86_64/docker-#{v}.tgz"
        sha256 "a43255b4564e7af19356637e543f6e95f856ba28144a06e68ea783c8687e7007"
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
