class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  if OS.linux?
    url "https://github.com/waltarix/choose/releases/download/v1.4.0-custom/choose-1.4.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "588c9e90aa2a0ff6e31be325a33fad3df879ed3001a13e204012646bf13360e8"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/choose/releases/download/v1.4.0-custom/choose-1.4.0-aarch64-apple-darwin.tar.xz"
      sha256 "f2a54e46c37eb2ab286bb184f5612b33217f5d39bec9432d65fb886a9112d05e"
    else
      url "https://github.com/waltarix/choose/releases/download/v1.4.0-custom/choose-1.4.0-x86_64-apple-darwin.tar.xz"
      sha256 "9eb919bd2ef189d0c4a5f885343acb3121e32873e716032bcfc48d87d5ed5d1b"
    end
  end
  license "GPL-3.0-or-later"

  conflicts_with "choose-gui", because: "both install a `choose` binary"
  conflicts_with "choose-rust", because: "both install a `choose` binary"

  def install
    bin.install "choose"

    generate_completions_from_executable(bin/"choose", "--completion")

    (man1/"choose.1").write Utils.safe_popen_read(bin/"choose", "--manpage")
  end

  test do
    input = "foo,  foobar,bar, baz"
    assert_equal "foobar bar", pipe_output("#{bin}/choose -f ',\\s*' 2:3", input).strip
  end
end
