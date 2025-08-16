class Less < Formula
  desc "Pager program similar to more"
  homepage "https://www.greenwoodsoftware.com/less/index.html"
  ["679", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    url "https://github.com/waltarix/less/releases/download/v#{v}-custom#{rev}/less-#{v}.tar.xz"
    sha256 "d604c30a2156f9e5bfea333ce7e0c4d5f7b0fb9990ff87fc7d99b88838c9a14d"
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
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    system "./configure", "--prefix=#{prefix}", "--with-regex=pcre2"
    system "make", "install"
  end

  test do
    system bin/"lesskey", "-V"
  end
end
