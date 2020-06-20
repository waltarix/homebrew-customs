class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://mosh.org/mosh-1.3.2.tar.gz"
  sha256 "da600573dfa827d88ce114e0fed30210689381bbdcff543c931e4d6a2e851216"
  revision 14

  bottle :unneeded

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
    url "https://github.com/waltarix/localedata/releases/download/13.0.0-r1/wcwidth9.h"
    sha256 "f00b5d73a1bb266c13bae2f9d758eaec59080ad8579cebe7d649ae125b28f9f1"
  end

  # Fix mojave build.
  unless build.head?
    patch do
      url "https://github.com/mobile-shell/mosh/commit/e5f8a826ef9ff5da4cfce3bb8151f9526ec19db0.patch?full_index=1"
      sha256 "022bf82de1179b2ceb7dc6ae7b922961dfacd52fbccc30472c527cb7c87c96f0"
    end
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
index 3ad983d..ffd3187 100644
--- a/configure.ac
+++ b/configure.ac
@@ -252,7 +252,6 @@ AC_CHECK_FUNCS(m4_normalize([
   strtok
   strerror
   strtol
-  wcwidth
   cfmakeraw
   pselect
   getaddrinfo
diff --git a/src/frontend/mosh-server.cc b/src/frontend/mosh-server.cc
index b90738f..a6e61fd 100644
--- a/src/frontend/mosh-server.cc
+++ b/src/frontend/mosh-server.cc
@@ -530,15 +530,6 @@ static int run_server( const char *desired_ip, const char *desired_port,
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
index 26d81cb..cb118e5 100644
--- a/src/frontend/terminaloverlay.cc
+++ b/src/frontend/terminaloverlay.cc
@@ -38,6 +38,8 @@
 
 #include "terminaloverlay.h"
 
+#include "wcwidth9.h"
+
 using namespace Overlay;
 using std::max;
 using std::mem_fun_ref;
@@ -267,7 +269,7 @@ void NotificationEngine::apply( Framebuffer &fb ) const
     }
 
     wchar_t ch = *i;
-    int chwidth = ch == L'\0' ? -1 : wcwidth( ch );
+    int chwidth = ch == L'\0' ? -1 : wcwidth9( ch );
     Cell *this_cell = 0;
 
     switch ( chwidth ) {
@@ -304,6 +306,7 @@ void NotificationEngine::apply( Framebuffer &fb ) const
       break;
     default:
       assert( false );
+      assert( !"unexpected character width from wcwidth9()" );
     }
   }
 }
@@ -727,7 +730,7 @@ void PredictionEngine::new_user_byte( char the_byte, const Framebuffer &fb )
 	    }
 	  }
 	}
-      } else if ( (ch < 0x20) || (wcwidth( ch ) != 1) ) {
+      } else if ( (ch < 0x20) || (wcwidth9( ch ) != 1) ) {
 	/* unknown print */
 	become_tentative();
 	//	fprintf( stderr, "Unknown print 0x%x\n", ch );
diff --git a/src/terminal/terminal.cc b/src/terminal/terminal.cc
index 2f9119b..537352b 100644
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
 
@@ -144,6 +146,7 @@ void Emulator::print( const Parser::Print *act )
     break;
   default:
     assert( false );
+    assert( !"unexpected character width from wcwidth9()" );
     break;
   }
 }
diff --git a/src/terminal/terminaldisplayinit.cc b/src/terminal/terminaldisplayinit.cc
index 50a0a35..bf4c8cf 100644
--- a/src/terminal/terminaldisplayinit.cc
+++ b/src/terminal/terminaldisplayinit.cc
@@ -124,7 +124,7 @@ Display::Display( bool use_environment )
        terminal type prefixes.  This is the list from Debian's default
        screenrc, plus "screen" itself (which also covers tmux). */
     static const char * const title_term_types[] = {
-      "xterm", "rxvt", "kterm", "Eterm", "screen"
+      "xterm", "rxvt", "kterm", "Eterm", "screen", "tmux"
     };
 
     has_title = false;
