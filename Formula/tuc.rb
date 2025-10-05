class Tuc < Formula
  desc "Text manipulation and cutting tool"
  homepage "https://github.com/riquito/tuc"
  ["1.3.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/tuc/releases/download/v#{v}-custom#{rev}/tuc-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "a6b00c921e55bee4dc597907525a6eabdf7c83b054bd46cc79f28649a9aba570"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/tuc/releases/download/v#{v}-custom#{rev}/tuc-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "7c874cbf9111b19f581f6a9d71974c33a11f484edf5175c6f2d7b80aab8b4dff"
      else
        url "https://github.com/waltarix/tuc/releases/download/v#{v}-custom#{rev}/tuc-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "0cdc14afbe2fad7e35827f10674a0c48b0f4167fc679fdb8ddac51b9c6634d51"
      end
    end
    revision r if r
  end
  license "GPL-3.0-or-later"

  def install
    bin.install "tuc"
    man1.install "man/tuc.1"
  end

  test do
    output = pipe_output("#{bin}/tuc -e '[, ]+' -f 1,3", "a,b, c")
    assert_equal "ac\n", output
  end
end
