class Ssrc < Formula
  desc "High Quality Audio Sampling Rate Converter"
  homepage "https://shibatch.sourceforge.io/"
  url "http://shibatch.sourceforge.net/download/ssrc-1.33.tar.gz"
  sha256 "a663082ca11d049a20d7598328e1646c9220d68005d793f992fc0618806d713a"

  def install
    ENV.deparallelize
    system "make"
    bin.install %w[ssrc ssrc_hp]
  end

  test do
    assert_match "version 1.33(single precision)", shell_output("#{bin}/ssrc", 255)
    assert_match "version 1.33(double precision)", shell_output("#{bin}/ssrc_hp", 255)
  end
end
