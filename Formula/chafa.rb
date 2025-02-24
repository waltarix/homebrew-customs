class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  url "https://hpjansson.org/chafa/releases/chafa-1.14.5.tar.xz"
  sha256 "7b5b384d5fb76a641d00af0626ed2115fb255ea371d9bef11f8500286a7b09e5"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://hpjansson.org/chafa/releases/?C=M&O=D"
    regex(/href=.*?chafa[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "glib"
  depends_on "jpeg-turbo"
  depends_on "libtiff"
  depends_on "webp"

  on_macos do
    depends_on "librsvg"
  end

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
    man1.install "docs/chafa.1"
  end

  test do
    output = shell_output("#{bin}/chafa #{test_fixtures("test.png")}")
    assert_equal 3, output.lines.count
    output = shell_output("#{bin}/chafa --version")
    expected_loaders = ["JPEG", "TIFF", "WebP"]
    expected_loaders << "SVG" if OS.mac?
    loaders = output.lines.find { |line| line.start_with?("Loaders:") }.split(/\s+/)
    assert_equal loaders & expected_loaders, expected_loaders
  end
end
