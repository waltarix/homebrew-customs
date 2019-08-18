class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/mobile-shell/mosh.git", :shallow => false
  version "1.3.2"
  sha256 "da600573dfa827d88ce114e0fed30210689381bbdcff543c931e4d6a2e851216"
  revision 8

  bottle do
    sha256 "5e05a95d972b509c0469ca933de7a522b74b049cc0dccfe5cb1aa6db34b54fc4" => :mojave
    sha256 "6cff59a934d2d8fda8f40f59c8ec5d0d2b550617478afa6ad56db20b3bb4e4a8" => :high_sierra
    sha256 "c62e3806458d92a044bd00f5ddf08d6a1d01ee5870f77b67c5527a4a81f44251" => :sierra
    sha256 "f990bb41dcdcc581c531138e235d58c6d83dfc53afe5203f44a0db7e92de4ead" => :el_capitan
  end

  def pour_bottle?
    false
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "perl" => :build if
    OS.linux? &&
    begin
      system_perl_version = Gem::Version.new(`/usr/bin/perl -e 'printf "%vd", $^V;'`)
      required_perl_version = Gem::Version.new("5.14.0")

      system_perl_version < required_perl_version
    end
  depends_on "pkg-config" => :build
  depends_on "tmux" => :build
  depends_on "protobuf"

  resource "wcwidth9.h" do
    url "https://gist.githubusercontent.com/waltarix/7a36cc9f234a4a2958a24927696cf87c/raw/d4a38bc596f798b0344d06e9c831677f194d8148/wcwidth9.h"
    sha256 "50b5f30757ed9e1f9bece87dec4d70e32eee780f42b558242e4e76b1f9b334c8"
  end

  patch :DATA

  def install
    ENV.cxx11

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    buildpath.install resource("wcwidth9.h")

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--enable-completion"
    system "make", "check"
    system "make", "install"
  end

  test do
    system bin/"mosh-client", "-c"
  end
end

__END__
diff --git a/configure.ac b/configure.ac
index e3f5626..ed95505 100644
--- a/configure.ac
+++ b/configure.ac
@@ -266,7 +266,6 @@ AC_CHECK_FUNCS(m4_normalize([
   strtok
   strerror
   strtol
-  wcwidth
   cfmakeraw
   pselect
   getaddrinfo
diff --git a/src/frontend/mosh-server.cc b/src/frontend/mosh-server.cc
index 21057e8..30c8b06 100644
--- a/src/frontend/mosh-server.cc
+++ b/src/frontend/mosh-server.cc
@@ -549,15 +549,6 @@ static int run_server( const char *desired_ip, const char *desired_port,
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
diff --git a/src/frontend/terminaloverlay.cc b/src/frontend/terminaloverlay.cc
index adee673..73a8bc3 100644
--- a/src/frontend/terminaloverlay.cc
+++ b/src/frontend/terminaloverlay.cc
@@ -38,6 +38,8 @@
 
 #include "terminaloverlay.h"
 
+#include "wcwidth9.h"
+
 using namespace Overlay;
 
 void ConditionalOverlayCell::apply( Framebuffer &fb, uint64_t confirmed_epoch, int row, bool flag ) const
@@ -261,7 +263,7 @@ void NotificationEngine::apply( Framebuffer &fb ) const
     }
 
     wchar_t ch = *i;
-    int chwidth = ch == L'\0' ? -1 : wcwidth( ch );
+    int chwidth = ch == L'\0' ? -1 : wcwidth9( ch );
     Cell *this_cell = 0;
 
     switch ( chwidth ) {
@@ -297,7 +299,7 @@ void NotificationEngine::apply( Framebuffer &fb ) const
     case -1: /* unprintable character */
       break;
     default:
-      assert( !"unexpected character width from wcwidth()" );
+      assert( !"unexpected character width from wcwidth9()" );
     }
   }
 }
@@ -743,7 +745,7 @@ void PredictionEngine::new_user_byte( char the_byte, const Framebuffer &fb )
 	    }
 	  }
 	}
-      } else if ( (ch < 0x20) || (wcwidth( ch ) != 1) ) {
+      } else if ( (ch < 0x20) || (wcwidth9( ch ) != 1) ) {
 	/* unknown print */
 	become_tentative();
 	//	fprintf( stderr, "Unknown print 0x%x\n", ch );
diff --git a/src/terminal/terminal.cc b/src/terminal/terminal.cc
index 057b3d0..66b2e73 100644
--- a/src/terminal/terminal.cc
+++ b/src/terminal/terminal.cc
@@ -38,6 +38,8 @@
 
 #include "terminal.h"
 
+#include "wcwidth9.h"
+
 using namespace Terminal;
 
 Emulator::Emulator( size_t s_width, size_t s_height )
@@ -66,7 +68,7 @@ void Emulator::print( const Parser::Print *act )
    * Check for printing ISO 8859-1 first, it's a cheap way to detect
    * some common narrow characters.
    */
-  const int chwidth = ch == L'\0' ? -1 : ( Cell::isprint_iso8859_1( ch ) ? 1 : wcwidth( ch ));
+  const int chwidth = ch == L'\0' ? -1 : ( Cell::isprint_iso8859_1( ch ) ? 1 : wcwidth9( ch ));
 
   Cell *this_cell = fb.get_mutable_cell();
 
@@ -142,7 +144,7 @@ void Emulator::print( const Parser::Print *act )
   case -1: /* unprintable character */
     break;
   default:
-    assert( !"unexpected character width from wcwidth()" );
+    assert( !"unexpected character width from wcwidth9()" );
     break;
   }
 }
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
