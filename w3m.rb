class W3m < Formula
  desc "Pager/text based browser"
  homepage "https://packages.debian.org/sid/w3m"
  url "https://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3+git20210102.orig.tar.xz"
  version "0.5.3+git20210102-6"
  sha256 "32fcf47999a4fab59021382d382add86fe87159d9e3a95bddafda246ae12f5f9"
  revision 1

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

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/14.0.0-r3/wcwidth9.h"
    sha256 "5797b11ba5712a6a98ad21ed2a2cec71467e2ccd4b0c7fd43ebb16a00ff85bda"
  end

  patch :DATA

  def install
    resource("wcwidth9.h").stage(buildpath/"libwc")

    # Work around configure issues with Xcode 12
    ENV.append "CFLAGS", "-Wno-implicit-function-declaration"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-gopher",
                          "--disable-ipv6",
                          "--disable-w3mmailer",
                          "--enable-image=no",
                          "--enable-japanese=U",
                          "--enable-m17n",
                          "--enable-nls",
                          "--enable-unicode",
                          "--with-gc",
                          "--with-migemo='cmigemo -c -q'",
                          "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}",
                          "--with-termlib=ncursesw"
    system "make", "install"
  end

  test do
    assert_match "DuckDuckGo", shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end

__END__
diff --git a/libwc/ucs.c b/libwc/ucs.c
index 18c3a67..6140f74 100644
--- a/libwc/ucs.c
+++ b/libwc/ucs.c
@@ -15,6 +15,8 @@
 #include "viet.h"
 #include "wtf.h"
 
+#include "wcwidth9.h"
+
 #include "ucs.map"
 
 #include "map/ucs_ambwidth.map"
@@ -536,14 +538,7 @@ wc_ucs_to_ccs(wc_uint32 ucs)
 wc_bool
 wc_is_ucs_ambiguous_width(wc_uint32 ucs)
 {
-    if (0xa1 <= ucs && ucs <= 0xfe && WcOption.use_jisx0213)
-	return 1;
-    else if (ucs <= WC_C_UCS2_END)
-	return (wc_map_range_search((wc_uint16)ucs,
-		    ucs_ambwidth_map, N_ucs_ambwidth_map) != NULL);
-    else
-	return ((0xF0000 <= ucs && ucs <= 0xFFFFD)
-		|| (0x100000 <= ucs && ucs <= 0x10FFFD));
+  return wcwidth9(ucs) == 2;
 }
 
 wc_bool
