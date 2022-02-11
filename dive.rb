class Dive < Formula
  desc "Tool for exploring each layer in a docker image"
  homepage "https://github.com/wagoodman/dive"
  if OS.linux?
    url "https://github.com/waltarix/dive/releases/download/v0.10.0-custom-r1/dive-0.10.0-linux_amd64.tar.xz"
    sha256 "dca975f5c8a9d37526784a3361151726263458b587c67e96c4c9822d1e623ba9"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dive/releases/download/v0.10.0-custom-r1/dive-0.10.0-darwin_arm64.tar.xz"
      sha256 "d00d1072a4c4fec862bc92402985f3712ba9ff9a13355706f33a89969607db72"
    else
      url "https://github.com/waltarix/dive/releases/download/v0.10.0-custom-r1/dive-0.10.0-darwin_amd64.tar.xz"
      sha256 "7c0a83ea1c68bc0994d1d1a97347730971b3c1e36a92010ba649faa08cf3d108"
    end
  end
  version "0.10.0"
  license "MIT"
  revision 1

  on_linux do
    depends_on "device-mapper"
  end

  def install
    bin.install "dive"
  end

  test do
    (testpath/"Dockerfile").write <<~EOS
      FROM alpine
      ENV test=homebrew-core
      RUN echo "hello"
    EOS

    assert_match "dive #{version}", shell_output("#{bin}/dive version")
    assert_match "Building image", shell_output("CI=true #{bin}/dive build .", 1)
  end
end
