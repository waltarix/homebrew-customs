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
      cellar :any
      sha256 "a718785bfd6faedca36df68c304a6a6e8a2f3c6068398695967bc59135f53a30" => :big_sur
      sha256 "d4eb24678f6346e5663ae34e9b73fd840265de17cfec03365c0102a7c70515e6" => :arm64_big_sur
      sha256 "3bfa0808fb4930926de52cf2fbb8cdbfd6f9a19f88b564c2e20dc9b024a44f79" => :catalina
      sha256 "45a87d847913835738fb388155f12522d1b711eeb2e2b8c032664cef673fad57" => :mojave
      sha256 "bf69ec9e729e9a8fe571eee779cbce37ddbd3b87acc9d13c647197a83af46a74" => :x86_64_linux
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
