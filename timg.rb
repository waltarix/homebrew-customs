class Timg < Formula
  desc "Terminal Image Viewer"
  homepage "https://github.com/hzeller/timg"
  url "https://github.com/hzeller/timg.git",
    :revision => "094da0b984f6943c1b52b4c7a81966378709466b"
  version "0.9.9-094da0b"

  depends_on "graphicsmagick"
  depends_on "ffmpeg" => :recommended

  def install
    inreplace "src/Makefile", " .FORCE", ""
    (buildpath/"src/timg-version.h").write <<~EOS
      #define TIMG_VERSION "0.9.9-094da0b"
    EOS

    cd "src" do
      system "make", "WITH_VIDEO_DECODING=#{build.with?("ffmpeg") ? 1 : 0}"

      bin.install "timg"
    end
  end

  test do
    system "#{bin}/timg", "-v"
  end
end
