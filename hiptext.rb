class Hiptext < Formula
  homepage 'https://github.com/jart/hiptext'
  url 'https://github.com/jart/hiptext.git'
  version '0.1'

  depends_on 'gflags'
  depends_on 'glog'
  depends_on 'libpng'
  depends_on 'jpeg'
  depends_on 'ffmpeg'
  depends_on 'freetype'
  depends_on 'ragel'

  def install
    system "make"

    bin.install "hiptext"
  end

  test do
    system "#{bin}/hiptext", "--version"
  end
end
