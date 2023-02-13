class Sd < Formula
  desc "Intuitive find & replace CLI"
  homepage "https://github.com/chmln/sd"
  if OS.linux?
    url "https://github.com/waltarix/sd/releases/download/v0.8.1-custom/sd-0.8.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "5ed1d121973318c9e28d77e4beaf594d075a651f9a1b78025f8b2c64ddae0a7b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/sd/releases/download/v0.8.1-custom/sd-0.8.1-aarch64-apple-darwin.tar.xz"
      sha256 "f257f6beb2b7bccd6b06413032b32bcc10f7e5b81ad954a1aac11877879631f4"
    else
      url "https://github.com/waltarix/sd/releases/download/v0.8.1-custom/sd-0.8.1-x86_64-apple-darwin.tar.xz"
      sha256 "c1b469d557814121759fcecb74bc3082db6fce3e085105fcd5663e0e29c68011"
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
