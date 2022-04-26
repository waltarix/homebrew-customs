class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  url "https://hpjansson.org/chafa/releases/static/chafa-1.10.2-1-x86_64-linux-gnu.tar.gz"
  sha256 "486026a11d200ce7e3a5ac38c56aabe82ce1d51a583f29fdbd74463cdb3cc1c3"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://hpjansson.org/chafa/releases/?C=M&O=D"
    regex(/href=.*?chafa[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on :linux

  resource "bottle" do
    url "https://ghcr.io/v2/homebrew/core/chafa/blobs/sha256:110de3d3360e9dbf8fddb87590a0b0ee876ce38fc2e6ea0f7f0a4cc69ab5c5aa"
    sha256 "110de3d3360e9dbf8fddb87590a0b0ee876ce38fc2e6ea0f7f0a4cc69ab5c5aa"
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
