class W3m < Formula
  desc "Pager/text based browser"
  homepage "https://w3m.sourceforge.io/"
  revision 6
  head "https://github.com/tats/w3m.git"

  stable do
    url "https://downloads.sourceforge.net/project/w3m/w3m/w3m-0.5.3/w3m-0.5.3.tar.gz"
    sha256 "e994d263f2fd2c22febfbe45103526e00145a7674a0fda79c822b97c2770a9e3"

    # Upstream is effectively Debian https://github.com/tats/w3m at this point.
    # The patches fix a pile of CVEs
    patch do
      url "https://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3-37.debian.tar.xz"
      sha256 "625f5b0cb71bf29b67ad3bb9c316420922877473a6e94e6c7bcc337cb22ce1eb"
      apply "patches/010_upstream.patch",
            "patches/020_debian.patch"
    end
  end

  bottle do
    rebuild 1
    sha256 "274f48d738d351b3c6a07ada24b866a485c49d400f36108d904a6d2a8835a660" => :catalina
    sha256 "c2a4f7208e98f575eadaff6af3dc9a93305008b93d2f069c53d687ba61b85d64" => :mojave
    sha256 "bc46bb9b70d7149058d2c757aa0b8ea68c7c6836faee26da0b697d81cca0927d" => :high_sierra
    sha256 "809a34cb2c14b98827cfe9f18008b0ebc545e359c5f8c1279e71948ac336bdd1" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "bdw-gc"
  depends_on "ncurses"
  depends_on "openssl@1.1"
  depends_on "waltarix/customs/cmigemo"
  depends_on "zlib"

  def pour_bottle?
    false
  end

  def install
    migemo = Formula["cmigemo"]
    with_migemo = "#{migemo.opt_bin}/cmigemo -q -d #{migemo.opt_share}/migemo/utf-8/migemo-dict"

    ncurses = Formula["ncurses"]
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-image",
                          "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}",
                          "--enable-unicode",
                          "--enable-nls",
                          "--enable-m17n",
                          "--with-termlib=ncursesw",
                          "--disable-ipv6",
                          "--with-migemo=#{with_migemo}"
    system "make", "install"
  end

  test do
    assert_match /DuckDuckGo/, shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end
