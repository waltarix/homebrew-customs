class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  url "https://hpjansson.org/chafa/releases/static/chafa-1.10.0-1-x86_64-linux-gnu.tar.gz"
  sha256 "42b9b96ea981a04222052a8f084d471f2ebdb0177fe01dbf391acdf13f0a34c4"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://hpjansson.org/chafa/releases/?C=M&O=D"
    regex(/href=.*?chafa[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on :linux

  resource "bottle" do
    url "https://ghcr.io/v2/homebrew/core/chafa/blobs/sha256:3a40584e711ca5da234e8ce86e6597f66197d3df8132fc7c5abf716bf1fe9e91"
    sha256 "3a40584e711ca5da234e8ce86e6597f66197d3df8132fc7c5abf716bf1fe9e91"
  end

  def install
    bin.install "chafa"

    resource("bottle").stage do
      man1.install "#{version}/share/man/man1/chafa.1"
    end
  end

  test do
    output = shell_output("#{bin}/chafa #{test_fixtures("test.png")}")
    assert_equal 4, output.lines.count
  end
end
