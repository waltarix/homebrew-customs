class Lz4json < Formula
  desc "C decompress tool for mozilla lz4json format"
  homepage "https://github.com/andikleen/lz4json"
  url "https://github.com/andikleen/lz4json.git",
    :tag => "v2"

  depends_on "lz4"

  def install
    system "make"

    bin.install("lz4jsoncat")
  end

  test do
    system "#{bin}/lz4jsoncat"
  end
end
