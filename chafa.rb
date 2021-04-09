class Chafa < Formula
  desc "Versatile and fast Unicode/ASCII/ANSI graphics renderer"
  homepage "https://hpjansson.org/chafa/"
  if OS.mac?
    url "https://hpjansson.org/chafa/releases/chafa-1.6.0.tar.xz"
    sha256 "0706e101a6e0e806335aeb57445e2f6beffe0be29a761f561979e81691c2c681"
  else
    url "https://hpjansson.org/chafa/releases/static/chafa-1.6.0-1-x86_64-linux-gnu.tar.gz"
    sha256 "3ba5a60e244dc6c2b928c2f75fe16fb4c094098699cfba6a6b1faebb73a5c4f4"
  end
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://hpjansson.org/chafa/releases/?C=M&O=D"
    regex(/href=.*?chafa[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  if OS.mac?
    bottle do
      sha256 cellar: :any, arm64_big_sur: "5bf09f7be13771c9e22b9e35db7837d6ba236ec92af1a95917f4c0610c805088"
      sha256 cellar: :any, big_sur:       "42420443f24f392f4b8f9318942ca4ee9838a516df05b6449c7cf9737e4a3c40"
      sha256 cellar: :any, catalina:      "6aa83c7ff29421d202351ebfc8f311d1e298ea7cded16609d0e07a52f0f76694"
      sha256 cellar: :any, mojave:        "1d8600db4b8fd0245678e831fb97ef592f1a5d5031a1b1a1dff4f0f910df846d"
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
