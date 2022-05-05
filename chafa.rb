class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  url "https://hpjansson.org/chafa/releases/static/chafa-1.10.3-1-x86_64-linux-gnu.tar.gz"
  sha256 "9c4bae507438af1ec96675b8a338516ecd1c94a65d7649d1334d2435e13bb25f"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://hpjansson.org/chafa/releases/?C=M&O=D"
    regex(/href=.*?chafa[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on :linux

  resource "bottle" do
    url "https://ghcr.io/v2/homebrew/core/chafa/blobs/sha256:682396e890521341156d6590ae0354d1e5f8f8337dec00bd4d5523d67fbd91da"
    sha256 "682396e890521341156d6590ae0354d1e5f8f8337dec00bd4d5523d67fbd91da"
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
