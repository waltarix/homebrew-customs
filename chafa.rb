class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  if OS.linux?
    url "https://hpjansson.org/chafa/releases/static/chafa-1.12.2-1-x86_64-linux-gnu.tar.gz"
    sha256 "3963bfcf9bc133a45f8d5ef29135336bc39f4cd1bfe6a2e818f2b41f49a195f1"
  else
    url "https://hpjansson.org/chafa/releases/chafa-1.12.2.tar.xz"
    sha256 "f41d44afb325a7fa0c095160723ddcc10fbd430a3ad674aa23e2426d713a96f5"
  end
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://hpjansson.org/chafa/releases/?C=M&O=D"
    regex(/href=.*?chafa[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  if OS.mac?
    depends_on "pkg-config" => :build
    depends_on "freetype"
    depends_on "glib"
    depends_on "jpeg"
    depends_on "librsvg"
    depends_on "libtiff"
    depends_on "webp"
  else
    resource "bottle" do
      url "https://ghcr.io/v2/homebrew/core/chafa/blobs/sha256:fa8bf974fe28dda61b53a2e332074121bfeae419e5ceb34dfd02c67d95355a8a"
      sha256 "fa8bf974fe28dda61b53a2e332074121bfeae419e5ceb34dfd02c67d95355a8a"
    end
  end

  def install
    if OS.mac?
      system "./configure", *std_configure_args, "--disable-silent-rules", "--without-imagemagick"
      system "make", "install"
      man1.install "docs/chafa.1"
    else
      bin.install "chafa"
      resource("bottle").stage { man1.install "#{version}/share/man/man1/chafa.1" }
    end
  end

  test do
    output = shell_output("#{bin}/chafa #{test_fixtures("test.png")}")
    assert_equal 2, output.lines.count
  end
end
