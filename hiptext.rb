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
  depends_on "ragel" => :build
  depends_on "pkg-config" => :build

  patch :DATA

  def install
    inreplace "src/movie.cc" do |s|
      s.gsub! "PIX_FMT_RGB24", "AV_PIX_FMT_RGB24"
      s.gsub! "avcodec_alloc_frame", "av_frame_alloc"
    end
    inreplace "src/font.cc", "DejaVuSansMono.ttf", "/System/Library/Fonts/Monaco.dfont"
    inreplace "src/hiptext.cc", %r{(?<=DEFINE_string\(bg, ")black}, "#000000"

    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["ffmpeg"].opt_lib}/pkgconfig"
    ENV["LIBGFLAGS_CFLAGS"] = "-I#{Formula["gflags"].opt_include}"
    ENV["LIBGFLAGS_LIBS"] = "-L#{Formula["gflags"].opt_lib} -lgflags"

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/hiptext", "--version"
  end
end

__END__
diff --git a/src/hiptext.cc b/src/hiptext.cc
index c106210..24e1272 100644
--- a/src/hiptext.cc
+++ b/src/hiptext.cc
@@ -202,9 +202,9 @@ int main(int argc, char** argv) {
   google::ParseCommandLineFlags(&argc, &argv, true);
   google::InitGoogleLogging(argv[0]);
   google::InstallFailureSignalHandler();
-  const char* lang = std::getenv("LANG");
-  if (lang == nullptr) lang = "en_US.utf8";
-  std::locale::global(std::locale(lang));
+  // const char* lang = std::getenv("LANG");
+  // if (lang == nullptr) lang = "en_US.utf8";
+  // std::locale::global(std::locale(lang));
   InitFont();
   Movie::InitializeMain();
