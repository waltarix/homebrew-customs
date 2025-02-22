class Less < Formula
  desc "Pager program similar to more"
  homepage "https://www.greenwoodsoftware.com/less/index.html"
  ["668", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    url "https://github.com/waltarix/less/releases/download/v#{v}-custom#{rev}/less-#{v}.tar.xz"
    sha256 "7d33129f24f7f35bf37bc7015b9cdd11239cc054a1b76daa20c53f99fca9ac5d"
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
