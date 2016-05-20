class W3m < Formula
  desc "Pager/text based browser"
  homepage "http://w3m.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/w3m/w3m/w3m-0.5.3/w3m-0.5.3.tar.gz"
  sha256 "e994d263f2fd2c22febfbe45103526e00145a7674a0fda79c822b97c2770a9e3"

  bottle do
    sha256 "c6443287699a058e58ff0e378a8f6459370de79f89246ac7217e11f9f748abed" => :el_capitan
    sha256 "57a644921789316e92cbc37d2e0c51eaf5591876992626a9bcf9f4a56c0e3897" => :yosemite
    sha256 "e2972a26e7c734e6814257516ebda796e907df5787906c4144321fc63e70f1a1" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "bdw-gc"
  depends_on "openssl"
  depends_on "cmigemo"
  depends_on "homebrew/dupes/ncurses"

  fails_with :llvm do
    build 2334
  end

  patch do
    sha256 "322f63c059e2f82dd6a76cc6e36c805fdaf86fecede164ebecd6ad1f7ab2acda"
    url "http://http.debian.net/debian/pool/main/w/w3m/w3m_0.5.3-27.debian.tar.xz"
    apply "patches/010_upstream.patch",
          "patches/020_debian.patch"
  end

  def pour_bottle?
    false
  end

  def install
    migemo = Formula["cmigemo"]
    with_migemo = %(#{migemo.opt_bin}/cmigemo -q -d #{migemo.opt_share}/migemo/utf-8/migemo-dict)

    system "./configure", "--prefix=#{prefix}", "--disable-image",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}",
                          "--enable-unicode",
                          "--enable-nls",
                          "--enable-m17n",
                          "--with-termlib=ncursesw",
                          "--disable-ipv6",
                          "--with-migemo=#{with_migemo}"
    # Race condition in build reported in:
    # https://github.com/Homebrew/homebrew/issues/12854
    ENV.j1
    system "make", "install"
  end

  test do
    assert_match /DuckDuckGo/, shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end
