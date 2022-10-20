class Sd < Formula
  desc "Intuitive find & replace CLI"
  homepage "https://github.com/chmln/sd"
  if OS.linux?
    url "https://github.com/waltarix/sd/releases/download/v0.8.0-custom/sd-0.8.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "379311bcdc360942bfe49ec0ad7642316f152e94f8a7de455433a6551a69474c"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/sd/releases/download/v0.8.0-custom/sd-0.8.0-aarch64-apple-darwin.tar.xz"
      sha256 "9fd163737901e46683dd42f3702cf8a52d8ceea228ac2ff38631b56c113923d2"
    else
      url "https://github.com/waltarix/sd/releases/download/v0.8.0-custom/sd-0.8.0-x86_64-apple-darwin.tar.xz"
      sha256 "d106421b210ed608e5596d2705000683eac59ca06f85f34cb95407167f45e8d1"
    end
  end
  license "MIT"

  def install
    bin.install "sd"
    man1.install "manual/sd.1"

    generate_completions_from_executable(bin/"sd", "--completion")
  end

  test do
    assert_equal "after", pipe_output("#{bin}/sd before after", "before")
  end
end
