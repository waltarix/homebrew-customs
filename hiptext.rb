class Hiptext < Formula
  desc "Turn images into text better than caca/aalib"
  homepage "https://github.com/jart/hiptext"
  url "https://github.com/jart/hiptext/releases/download/0.2/hiptext-0.2.tar.gz"
  sha256 "7f2217dec8775b445be6745f7bd439c24ce99c4316a9faf657bee7b42bc72e8f"

  depends_on "gflags"
  depends_on "glog"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "ffmpeg"
  depends_on "freetype"
  depends_on "ragel"
  depends_on "pkg-config" => :build

  def install
    inreplace "src/movie.cc" do |s|
      s.gsub! "PIX_FMT_RGB24", "AV_PIX_FMT_RGB24"
      s.gsub! "avcodec_alloc_frame", "av_frame_alloc"
    end

    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["ffmpeg"].opt_lib}/pkgconfig"
    ENV["LIBGFLAGS_CFLAGS"] = "-I#{Formula["gflags"].opt_include}"
    ENV["LIBGFLAGS_LIBS"] = "-L#{Formula["gflags"].opt_lib} -lgflags"

    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/hiptext", "--version"
  end
end
