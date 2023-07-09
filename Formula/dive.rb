class Dive < Formula
  desc "Tool for exploring each layer in a docker image"
  homepage "https://github.com/wagoodman/dive"
  "0.11.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dive/releases/download/v#{v}-custom/dive-#{v}-linux_amd64.tar.xz"
      sha256 "1d9a4bec157c0c745f3344834e845a397c1ccbc4437fea1830f9abf042c488f9"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dive/releases/download/v#{v}-custom/dive-#{v}-darwin_arm64.tar.xz"
        sha256 "f8c6fa8bba875eff6e3e35987eb29caae609e2ff14f9c2802635609136282d05"
      else
        url "https://github.com/waltarix/dive/releases/download/v#{v}-custom/dive-#{v}-darwin_amd64.tar.xz"
        sha256 "bb7f283ebbd5482e768f5a1bc904a90be32258673bfe970cd16181f2760b957f"
      end
    end
    version v
  end
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
