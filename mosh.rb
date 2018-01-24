class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/mobile-shell/mosh.git", :shallow => false
  version "1.3.2"
  sha256 "da600573dfa827d88ce114e0fed30210689381bbdcff543c931e4d6a2e851216"
  revision 4

  bottle do
    sha256 "a6978eda44965301af1ca77cec8cdcbda2ccb123ae43959ecb9a143fb745b0cd" => :high_sierra
    sha256 "6a1a87842665366e6dddb88426ae43fd5508b595a72a561f5c6b4a892d373f57" => :sierra
    sha256 "996904520d84a4d00557f399888e934fe4011719009e5662d49749ab0b83c89e" => :el_capitan
  end

  option "with-test", "Run build-time tests"

  deprecated_option "without-check" => "without-test"

  depends_on "pkg-config" => :build
  depends_on "protobuf"
  depends_on "tmux" => :build if build.with?("test") || build.bottle?
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "waltarix/customs/wcwidth-cjk"
  depends_on "perl" => :build if
    OS.linux? &&
    begin
      system_perl_version = Gem::Version.new(`/usr/bin/perl -e 'printf "%vd", $^V;'`)
      required_perl_version = Gem::Version.new("5.14.0")

      system_perl_version < required_perl_version
    end

  def pour_bottle?
    false
  end

  patch :DATA

  def install
    ENV.append "LDFLAGS", "-L#{Formula["wcwidth-cjk"].lib} -lwcwidth-cjk"

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--enable-completion"
    system "make", "check" if build.with?("test") || build.bottle?
    system "make", "install"
  end

  test do
    system bin/"mosh-client", "-c"
  end
end

__END__
diff --git a/src/frontend/mosh-server.cc b/src/frontend/mosh-server.cc
index 7918c74..ae5fca4 100644
--- a/src/frontend/mosh-server.cc
+++ b/src/frontend/mosh-server.cc
@@ -552,15 +552,6 @@ static int run_server( const char *desired_ip, const char *desired_port,
     }
 #endif /* HAVE_IUTF8 */
 
-    /* set TERM */
-    const char default_term[] = "xterm";
-    const char color_term[] = "xterm-256color";
-
-    if ( setenv( "TERM", (colors == 256) ? color_term : default_term, true ) < 0 ) {
-      perror( "setenv" );
-      exit( 1 );
-    }
-
     /* ask ncurses to send UTF-8 instead of ISO 2022 for line-drawing chars */
     if ( setenv( "NCURSES_NO_UTF8_ACS", "1", true ) < 0 ) {
       perror( "setenv" );
diff --git a/src/terminal/terminaldisplayinit.cc b/src/terminal/terminaldisplayinit.cc
index 54dfcc9..9720f26 100644
--- a/src/terminal/terminaldisplayinit.cc
+++ b/src/terminal/terminaldisplayinit.cc
@@ -115,7 +115,7 @@ Display::Display( bool use_environment )
        terminal type prefixes.  This is the list from Debian's default
        screenrc, plus "screen" itself (which also covers tmux). */
     static const char * const title_term_types[] = {
-      "xterm", "rxvt", "kterm", "Eterm", "screen"
+      "xterm", "rxvt", "kterm", "Eterm", "screen", "tmux"
     };
 
     has_title = false;
