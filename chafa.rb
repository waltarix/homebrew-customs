class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  if OS.mac?
    url "https://hpjansson.org/chafa/releases/chafa-1.4.1.tar.xz"
    sha256 "46d34034f4c96d120e0639f87a26590427cc29e95fe5489e903a48ec96402ba3"
  else
    url "https://hpjansson.org/chafa/releases/static/chafa-1.4.1-1-x86_64-linux-gnu.tar.gz"
    sha256 "ff7c37e6c8790a34dc7042c8c226b45a0f2aabdad660ad5358063980d43dd650"
  end
  license "GPL-3.0"

  if OS.mac?
    bottle do
      cellar :any
      sha256 "f8285220cba2737c58bea611f3c0b653b3c5e1306b8cef3ff33642ed26260fb8" => :catalina
      sha256 "a483480366443ac91c52ebab6a06d0995a541098ce163a03c6cef71c0829be1c" => :mojave
      sha256 "272891299f7962a49755de583274a21a49759e020418586fa0e7cdfe7c8e2202" => :high_sierra
      sha256 "d58a4f786612b2f204f4f80088c24338be9c0136343cf8a87173bd0184a935c4" => :x86_64_linux
    end
  else
    bottle :unneeded
  end

  if OS.mac?
    depends_on "pkg-config" => :build
    depends_on "glib"
    depends_on "imagemagick"
  end

  def install
    if OS.mac?
      system "./configure", "--disable-debug",
                            "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}"
      system "make", "install"
    else
      bin.install "chafa"
    end
  end

  test do
    output = shell_output("#{bin}/chafa #{test_fixtures("test.png")}")
    assert_equal 4, output.lines.count
  end
end
