class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  if OS.mac?
    url "https://hpjansson.org/chafa/releases/chafa-1.8.0.tar.xz"
    sha256 "21ff652d836ba207098c40c459652b2f1de6c8a64fbffc62e7c6319ced32286b"
  else
    url "https://hpjansson.org/chafa/releases/static/chafa-1.8.0-1-x86_64-linux-gnu.tar.gz"
    sha256 "a981e8a99e1993b799bd24afb93880e2a02d4c395868223c48f648cccc642168"
  end
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://hpjansson.org/chafa/releases/?C=M&O=D"
    regex(/href=.*?chafa[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  if OS.mac?
    bottle do
      sha256 cellar: :any, arm64_big_sur: "ec3e9511b3a0ce9c08156e0129bc1b6b457bb872633ffad80e3dc75500ebd665"
      sha256 cellar: :any, big_sur:       "978b79d0ad33901c14156632e34a1b8eba5a0256c92662dde6b9ec2cff0600f8"
      sha256 cellar: :any, catalina:      "8603c4aea080189a148ca7097146edfd5c79fd0ddcc52ffca94eb5d8709ecff5"
      sha256 cellar: :any, mojave:        "3b2b88dae2564f4f2d83f10f55d16866e50a1e8294a409562633d48d618252f3"
    end

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
      bin.install "chafa-linux-x86_64" => "chafa"
    end
  end

  test do
    output = shell_output("#{bin}/chafa #{test_fixtures("test.png")}")
    assert_equal 4, output.lines.count
  end
end
