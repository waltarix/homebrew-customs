class Dive < Formula
  desc "Tool for exploring each layer in a docker image"
  homepage "https://github.com/wagoodman/dive"
  if OS.linux?
    url "https://github.com/waltarix/dive/releases/download/v0.10.0-custom/dive-0.10.0-linux_amd64.tar.xz"
    sha256 "6262aea4c8665381e37614473f3618345e9aa53444819ff89903d15e7fde2141"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dive/releases/download/v0.10.0-custom/dive-0.10.0-darwin_arm64.tar.xz"
      sha256 "7eaf11a3bf843580e42ef6a585dcac8abd40583f62a2abdc0a472bd85318859a"
    else
      url "https://github.com/waltarix/dive/releases/download/v0.10.0-custom/dive-0.10.0-darwin_amd64.tar.xz"
      sha256 "6011a3345ea792af0950cbda8701546c0e178f92504f2f7eb30c336e050e2901"
    end
  end
  version "0.10.0"
  license "MIT"

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
