class Hiptext < Formula
  homepage 'https://github.com/jart/hiptext'
  url 'https://github.com/jart/hiptext.git'
  version '0.1'

  depends_on 'gcc'
  depends_on 'gflags'
  depends_on 'glog'
  depends_on 'libpng'
  depends_on 'jpeg'
  depends_on 'ffmpeg'
  depends_on 'freetype'
  depends_on 'ragel'

  fails_with :llvm
  fails_with :clang
  fails_with :gcc

  def install
    system "make"

    bin.install "hiptext"
  end

  test do
    system "#{bin}/hiptext", "--version"
  end
end