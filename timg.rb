class Timg < Formula
  desc "Terminal Image Viewer"
  homepage "https://github.com/hzeller/timg"
  url "https://github.com/hzeller/timg.git",
    :revision => "218830b9ca56453a553e9c96a6abdf1d013076b2"
  version "0.9.5-beta2"

  depends_on "graphicsmagick" => [:build, "with-webp"]

  patch :DATA

  def install
    cd "src" do
      system "make"

      bin.install "timg"
    end
  end

  test do
    system "#{bin}/timg", "-v"
  end
end

__END__
diff --git a/src/timg.cc b/src/timg.cc
index bd66f93..b5ce20d 100644
--- a/src/timg.cc
+++ b/src/timg.cc
@@ -34,7 +34,7 @@
 
 #include <vector>
 
-#define TIMG_VERSION "0.9.1beta"
+#define TIMG_VERSION "0.9.5-beta2"
 
 volatile bool interrupt_received = false;
 static void InterruptHandler(int signo) {
