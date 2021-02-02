class W3m < Formula
  desc "Pager/text based browser"
  homepage "https://w3m.sourceforge.io/"
  url "http://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3+git20210102.orig.tar.xz"
  version "0.5.3+git20210102-2"
  sha256 "32fcf47999a4fab59021382d382add86fe87159d9e3a95bddafda246ae12f5f9"

  bottle :unneeded

  depends_on "pkg-config" => :build
  depends_on "bdw-gc"
  depends_on "ncurses"
  depends_on "openssl@1.1"
  depends_on "waltarix/customs/cmigemo"
  depends_on "zlib"
  on_linux do
    depends_on "gettext"
    depends_on "libbsd"
  end

  patch do
    url "http://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3+git20210102-2.debian.tar.xz"
    sha256 "ac9a1035bb354387dd618c3610ce98ab4d3e43163ea3561643fa613e781e3244"
    apply "patches/010_section.patch"
  end

  def install
    # Work around configure issues with Xcode 12
    ENV.append "CFLAGS", "-Wno-implicit-function-declaration"

    system "./configure", "--prefix=#{prefix}",
                          "--with-gc",
                          "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}",
                          "--with-termlib=ncursesw",
                          "--with-migemo='cmigemo -c -q'",
                          "--disable-image",
                          "--enable-m17n", "--enable-unicode", "--enable-nls"
    system "make", "install"
  end

  test do
    assert_match /DuckDuckGo/, shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end
