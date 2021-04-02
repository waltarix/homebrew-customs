class W3m < Formula
  desc "Pager/text based browser"
  homepage "https://packages.debian.org/sid/w3m"
  url "https://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3+git20210102.orig.tar.xz"
  version "0.5.3+git20210102-6"
  sha256 "32fcf47999a4fab59021382d382add86fe87159d9e3a95bddafda246ae12f5f9"

  patch do
    url "https://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3+git20210102-6.debian.tar.xz"
    sha256 "ef6f835be35815580bc0f4683e7dd2e6f4ce411072d12dbccbd52051b5fa8770"
    apply "patches/010_section.patch",
          "patches/030_str-overflow.patch",
          "patches/040_libwc-overflow.patch"

  end

  livecheck do
    url "https://deb.debian.org/debian/pool/main/w/w3m/"
    regex(/href=.*?w3m[._-]v?(\d+(?:\.\d+)+)\.orig\.t/i)
  end

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

  def install
    # Work around configure issues with Xcode 12
    ENV.append "CFLAGS", "-Wno-implicit-function-declaration"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-image",
                          "--enable-m17n",
                          "--enable-nls",
                          "--enable-unicode",
                          "--with-gc",
                          "--with-migemo='cmigemo -c -q'",
                          "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}",
                          "--with-with-termlib=ncursesw"
    system "make", "install"
  end

  test do
    assert_match "DuckDuckGo", shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end
