class Timg < Formula
  desc "Terminal Image Viewer"
  homepage "https://github.com/hzeller/timg"
  url "https://github.com/hzeller/timg.git",
    :revision => "d750dc0f623110108a83bc5e145f8ec4259296b4"
  version "0.9.5-beta1"
  revision 1

  depends_on "graphicsmagick" => ["with-webp", :build]

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
diff --git a/src/terminal-canvas.cc b/src/terminal-canvas.cc
index be878f3..3963dca 100644
--- a/src/terminal-canvas.cc
+++ b/src/terminal-canvas.cc
@@ -33,7 +33,7 @@
 
 // Each character on the screen is divided in a top pixel and bottom pixel.
 // We use the following character which fills the top block:
-#define PIXEL_CHARACTER  "▀"  // Top foreground color, bottom background color
+#define PIXEL_CHARACTER  " "  // Top foreground color, bottom background color
 
 // Now, pixels on the even row will get the foreground color changed, pixels
 // on odd rows the background color. Two pixels one stone. Or something.
diff --git a/src/timg.cc b/src/timg.cc
index bd66f93..b5ce20d 100644
--- a/src/timg.cc
+++ b/src/timg.cc
@@ -34,7 +34,7 @@
 
 #include <vector>
 
-#define TIMG_VERSION "0.9.1beta"
+#define TIMG_VERSION "0.9.5-beta1"
 
 volatile bool interrupt_received = false;
 static void InterruptHandler(int signo) {
