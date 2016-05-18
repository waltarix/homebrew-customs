class Less < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "http://www.greenwoodsoftware.com/less/less-481.tar.gz"
  sha256 "3fa38f2cf5e9e040bb44fffaa6c76a84506e379e47f5a04686ab78102090dda5"

  bottle do
    sha256 "b38f31c863dff20e1d317ca6c046effbf154b134d24daff1ed4a34feb267d6a8" => :el_capitan
    sha256 "5295b62edf0ba63b2b67c327e3345f727404975005645328a78826f66445d1a1" => :yosemite
    sha256 "c12b5ad0d9859e185b7c7f5d33537c248c0463fcbd786290280b6aa5a1be9f98" => :mavericks
  end

  def pour_bottle?
    false
  end

  depends_on "pcre"
  depends_on "homebrew/dupes/ncurses"

  def install
    args = ["--prefix=#{prefix}"]
    args << "--with-regex=pcre"
    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end
