class W3m < Formula
  desc "Pager/text based browser"
  homepage "https://w3m.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/w3m/w3m/w3m-0.5.3/w3m-0.5.3.tar.gz"
  version "0.5.3-38"
  sha256 "e994d263f2fd2c22febfbe45103526e00145a7674a0fda79c822b97c2770a9e3"

  bottle :unneeded

  depends_on "pkg-config" => :build
  depends_on "bdw-gc"
  depends_on "ncurses"
  depends_on "openssl@1.1"
  depends_on "waltarix/customs/cmigemo"
  depends_on "zlib"
  unless OS.mac?
    depends_on "libbsd"
    depends_on "gettext"
  end

  # Upstream is effectively Debian https://github.com/tats/w3m at this point.
  # The patches fix a pile of CVEs
  patch do
    url "https://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3-38.debian.tar.xz"
    sha256 "227dd8d27946f21186d74ac6b7bcf148c37d97066c7ccded16495d9e22520792"
    apply "patches/010_upstream.patch",
          "patches/020_debian.patch"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-image",
                          "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}",
                          "--enable-m17n",
                          "--enable-nls",
                          "--enable-unicode",
                          "--with-gc",
                          "--with-termlib=ncursesw",
                          "--with-migemo='cmigemo -c -q'"
    system "make", "install"
  end

  test do
    assert_match /DuckDuckGo/, shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end
