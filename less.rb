require 'formula'

class Less < Formula
  homepage 'http://www.greenwoodsoftware.com/less/index.html'
  url 'http://www.greenwoodsoftware.com/less/less-471.tar.gz'
  sha1 '0d030b56f3f9c3ed68c6498876a27e0cac430538'

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/dupes"
    sha1 "39ee5dcbfa07bc32b84fc5b3be03cb571231beb7" => :yosemite
    sha1 "a3589555443a08e2e9c858a72fe30d0bbf8a4968" => :mavericks
    sha1 "76de5c62e907e6821309aeec0031ba8185b8ea93" => :mountain_lion
  end

  def pour_bottle?
    false
  end

  depends_on 'pcre'
  depends_on 'ncurses'

  def install
    args = ["--prefix=#{prefix}"]
    args << '--with-regex=pcre'
    system "./configure", *args
    system "make install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end
