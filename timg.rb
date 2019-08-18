class Timg < Formula
  desc "Terminal Image Viewer"
  homepage "https://github.com/hzeller/timg"
  url "https://github.com/hzeller/timg.git",
    :revision => "4a300cfe9c159ffb5d357b41b3c69c57219da9e8"
  version "0.9.5-beta4"

  depends_on "graphicsmagick"

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
+#define TIMG_VERSION "0.9.5-beta4"
 
 volatile bool interrupt_received = false;
 static void InterruptHandler(int signo) {
