class DockerCompletion < Formula
  desc "Bash, Zsh and Fish completion for Docker"
  homepage "https://www.docker.com/"
  "24.0.6".tap do |v|
    if OS.linux?
      url "https://download.docker.com/linux/static/stable/x86_64/docker-#{v}.tgz"
      sha256 "99792dec613df93169a118b05312a722a63604b868e4c941b1b436abcf3bb70f"
    else
      if Hardware::CPU.arm?
        url "https://download.docker.com/mac/static/stable/aarch64/docker-#{v}.tgz"
        sha256 "0f05ed10fe725a048c999d26d7bd11844ccc3522c2eddc9ad9a4d84c4a03417d"
      else
        url "https://download.docker.com/mac/static/stable/x86_64/docker-#{v}.tgz"
        sha256 "e1270cd0f9fa039de4635de030706a146274daa324d0caafa660f968d44a8e31"
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
