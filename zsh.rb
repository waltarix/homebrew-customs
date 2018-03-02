class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  url "https://downloads.sourceforge.net/project/zsh/zsh/5.4.2/zsh-5.4.2.tar.gz"
  mirror "https://www.zsh.org/pub/zsh-5.4.2.tar.gz"
  sha256 "957bcdb2c57f64c02f673693ea5a7518ef24b6557aeb3a4ce222cefa6d74acc9"
  revision 5

  bottle do
    sha256 "9071f9ae246b1c2d577cf0e2115f38e3612994d456a1925918c9ea25218c202d" => :high_sierra
    sha256 "daa5e14fd14dd3051ac99e29d3c8ec5954f99e613229c200c1898d8e682549af" => :sierra
    sha256 "1dbc516e7193753876e2d1648cfb90c0d15fb3f0c6483a929fbcc4b129be0d46" => :el_capitan
  end

  head do
    url "https://git.code.sf.net/p/zsh/code.git"
    depends_on "autoconf" => :build
  end

  def pour_bottle?
    false
  end

  option "without-etcdir", "Disable the reading of Zsh rc files in /etc"
  option "with-unicode9", "Build with Unicode 9 character width support"

  deprecated_option "disable-etcdir" => "without-etcdir"

  depends_on "pcre"
  depends_on "ncurses"
  depends_on "texinfo" => :build if OS.linux?
  depends_on "gdbm" => :optional

  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.4.2/zsh-5.4.2-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.4.2-doc.tar.xz"
    sha256 "5229cc93ebe637a07deb5b386b705c37a50f4adfef788b3c0f6647741df4f6bd"
  end

  def install
    ncurses = Formula["ncurses"]

    ENV.append "LDFLAGS", "-L#{ncurses.lib}"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}"

    system "Util/preconfig" if build.head?

    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{pkgshare}/functions
      --enable-scriptdir=#{pkgshare}/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-runhelpdir=#{pkgshare}/help
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
      --with-term-lib=ncursesw
      --enable-unicode9
    ]

    args << "--disable-gdbm" if build.without? "gdbm"

    if build.without? "etcdir"
      args << "--disable-etcdir"
    else
      args << "--enable-etcdir=/etc"
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    if build.head?
      # disable target install.man, because the required yodl comes neither with macOS nor Homebrew
      # also disable install.runhelp and install.info because they would also fail or have no effect
      system "make", "install.bin", "install.modules", "install.fns"
    else
      system "make", "install"
      system "make", "install.info"

      resource("htmldoc").stage do
        (pkgshare/"htmldoc").install Dir["Doc/*.html"]
      end
    end
  end

  test do
    assert_equal "homebrew", shell_output("#{bin}/zsh -c 'echo homebrew'").chomp
    system bin/"zsh", "-c", "printf -v hello -- '%s'"
  end
end

__END__
diff --git a/Src/wcwidth9.h b/Src/wcwidth9.h
index 448f548..b436c11 100644
--- a/Src/wcwidth9.h
+++ b/Src/wcwidth9.h
@@ -518,9 +518,7 @@ static const struct wcwidth9_interval wcwidth9_ambiguous[] = {
   {0x22bf, 0x22bf},
   {0x2312, 0x2312},
   {0x2460, 0x24e9},
-  {0x24eb, 0x254b},
   {0x2550, 0x2573},
-  {0x2580, 0x258f},
   {0x2592, 0x2595},
   {0x25a0, 0x25a1},
   {0x25a3, 0x25a9},
@@ -561,7 +559,8 @@ static const struct wcwidth9_interval wcwidth9_ambiguous[] = {
   {0x2776, 0x277f},
   {0x2b56, 0x2b59},
   {0x3248, 0x324f},
-  {0xe000, 0xf8ff},
+  {0xe000, 0xe09f},
+  {0xe0d8, 0xf8ff},
   {0xfe00, 0xfe0f},
   {0xfffd, 0xfffd},
   {0x1f100, 0x1f10a},
