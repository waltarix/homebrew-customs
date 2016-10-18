class Hiptext < Formula
  desc "Turn images into text better than caca/aalib"
  homepage "https://github.com/jart/hiptext"
  url 'https://github.com/waltarix/hiptext.git',
    :tag => '0.3'

  depends_on "gflags"
  depends_on "glog"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "ffmpeg28" => ["--with-openssl", "--with-webp", "--with-libquvi"]
  depends_on "freetype"
  depends_on "ragel" => :build
  depends_on "pkg-config" => :build
  depends_on "automake" => :build
  depends_on "autoconf" => :build

  patch :DATA

  def install
    inreplace "src/hiptext.cc", %r{(?<=DEFINE_string\(bg, ")black}, "#000000"
    inreplace "src/font.cc", "DejaVuSansMono.ttf", "/System/Library/Fonts/Monaco.dfont" if OS.mac?

    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["ffmpeg28"].opt_lib}/pkgconfig"
    ENV["LIBGFLAGS_CFLAGS"] = "-I#{Formula["gflags"].opt_include}"
    ENV["LIBGFLAGS_LIBS"] = "-L#{Formula["gflags"].opt_lib} -lgflags"

    system "aclocal"
    system "automake -a"
    system "autoconf"

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
index 2222347..495ca40 100644
--- a/src/hiptext.cc
+++ b/src/hiptext.cc
@@ -226,9 +226,9 @@ int main(int argc, char** argv) {
   google::ParseCommandLineFlags(&argc, &argv, true);
   google::InitGoogleLogging(argv[0]);
   google::InstallFailureSignalHandler();
-  const char* lang = std::getenv("LANG");
-  if (lang == nullptr) lang = "en_US.utf8";
-  std::locale::global(std::locale(lang));
+  //const char* lang = std::getenv("LANG");
+  //if (lang == nullptr) lang = "en_US.utf8";
+  //std::locale::global(std::locale(lang));
   InitFont();
   Movie::InitializeMain();
 
