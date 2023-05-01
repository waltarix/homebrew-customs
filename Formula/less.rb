class Less < Formula
  desc "Pager program similar to more"
  homepage "https://www.greenwoodsoftware.com/less/index.html"
  "632".tap do |v|
    url "https://github.com/waltarix/less/releases/download/v#{v}-custom/less-#{v}.tar.xz"
    sha256 "53dceb1377ca183a8739fb4551274511c509345faf592a57350ebbc290051643"
  end
  license "GPL-3.0-or-later"

  livecheck do
    url :homepage
    regex(/less[._-]v?(\d+(?:\.\d+)*).+?released.+?general use/i)
  end

  depends_on "ncurses"
  depends_on "pcre2"
  depends_on "waltarix/customs/cmigemo"

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    system "./configure", "--prefix=#{prefix}", "--with-regex=pcre2"
    system "make", "install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end
