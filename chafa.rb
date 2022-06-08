class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  if OS.linux?
    url "https://hpjansson.org/chafa/releases/static/chafa-1.12.0-1-x86_64-linux-gnu.tar.gz"
    sha256 "3e7f3b89f32207710e9e9c9bc448b8d6c8ce85c0b6f14e210f6a1a1fd0696380"
  else
    url "https://hpjansson.org/chafa/releases/chafa-1.12.0.tar.xz"
    sha256 "aafde6275e498f34e5120b56dc20dd15f6bb5e9b35ac590f52fde5ad6b2c7319"
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

    # Fix -flat_namespace being used on Big Sur and later.
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
      sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
    end
  else
    resource "bottle" do
      url "https://ghcr.io/v2/homebrew/core/chafa/blobs/sha256:66b6fb5879df30ae0af6391ea1704b01adf6d7c117f6aab8de516090368348e0"
      sha256 "66b6fb5879df30ae0af6391ea1704b01adf6d7c117f6aab8de516090368348e0"
    end
  end

  def install
    if OS.mac?
      system "./configure", "--disable-debug",
                            "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--without-imagemagick",
                            "--prefix=#{prefix}"
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
