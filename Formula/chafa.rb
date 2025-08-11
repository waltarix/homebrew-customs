class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  url "https://hpjansson.org/chafa/releases/chafa-1.16.2.tar.xz"
  sha256 "657898dd9a89b45130a44c1efe1fc03e2c7bd00c2f543ed7111613cb9e7861df"
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
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
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
