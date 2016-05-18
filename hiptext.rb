class Hiptext < Formula
  desc "Turn images into text better than caca/aalib"
  homepage "https://github.com/jart/hiptext"
  url "https://github.com/jart/hiptext.git"
  version "0.1"

  depends_on "gflags"
  depends_on "glog"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "ffmpeg"
  depends_on "freetype"
  depends_on "ragel"

  def install
    inreplace "movie.cc" do |s|
      s.gsub! "PIX_FMT_RGB24", "AV_PIX_FMT_RGB24"
      s.gsub! "avcodec_alloc_frame", "av_frame_alloc"
    end

    system "make"

    bin.install "hiptext"
  end

  test do
    system "#{bin}/hiptext", "--version"
  end
end
