class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  url "https://hpjansson.org/chafa/releases/chafa-1.12.4.tar.xz"
  sha256 "9774bd1a7076ea3124f7fea811e371d0e1da2e76b7ac06260d63a86c7b1a573f"
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

    on_macos do
      ENV.append "CFLAGS", "-flto"
    end

    system "./configure", *std_configure_args, "--disable-silent-rules", "--without-imagemagick"
    system "make", "install"
    man1.install "docs/chafa.1"
  end

  test do
    output = shell_output("#{bin}/chafa #{test_fixtures("test.png")}")
    assert_equal 2, output.lines.count
    output = shell_output("#{bin}/chafa --version")
    expected_loaders = ["JPEG", "TIFF", "WebP"]
    expected_loaders << "SVG" if OS.mac?
    loaders = output.lines.find { |line| line.start_with?("Loaders:") }.split(/\s+/)
    assert_equal loaders & expected_loaders, expected_loaders
  end
end
