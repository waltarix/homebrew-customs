class Align < Formula
  desc "Text column alignment filter"
  homepage "https://kinzler.com/me/align/"
  url "https://kinzler.com/me/align/align-1.7.5.tgz"
  sha256 "cc692fb9dee0cc288757e708fc1a3b6b56ca1210ca181053a371cb11746969dd"
  license "GPL-2.0-or-later"
  revision 1

  livecheck do
    url :homepage
    regex(/href=.*?align[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  on_macos do
    uses_from_macos "perl"
  end

  conflicts_with "speech-tools", because: "both install `align` binaries"

  resource "Text::CharWidth" do
    url "https://cpan.metacpan.org/authors/id/K/KU/KUBOTA/Text-CharWidth-0.04.tar.gz"
    sha256 "abded5f4fdd9338e89fd2f1d8271c44989dae5bf50aece41b6179d8e230704f8"

    patch :DATA
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/14.0.0/wcwidth9.h"
    sha256 "30a2baeb3c98096d007f9aa5c1f7bc6036a1674c71769477d47fbb0a31b9cbf5"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
    ENV.prepend_path "PERL5LIB", libexec/"lib"

    resource("Text::CharWidth").stage(buildpath/"text_charwidth")
    (buildpath/"text_charwidth").install resource("wcwidth9.h")
    cd "text_charwidth" do
      on_linux do
        perl_archlib = Utils.safe_popen_read("perl", "-MConfig", "-e", "print $Config{archlib}")
        ENV["C_INCLUDE_PATH"] = "#{perl_archlib}/CORE"
      end

      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
      system "make", "install"
    end

    inreplace ["align", "width"], %r{(?=^use Getopt::Std)}, "use Text::CharWidth qw(mbswidth);\n"
    inreplace ["align", "width"], "length(", "mbswidth("
    inreplace "width", %r{(?<=^\$process = ).+}, "0;"

    system "make"

    libexec.install ["align", "width"]
    chmod 0755, Dir["#{libexec}/*"]
    (bin/"align").write_env_script("#{libexec}/align", PERL5LIB: ENV["PERL5LIB"])
    (bin/"width").write_env_script("#{libexec}/width", PERL5LIB: ENV["PERL5LIB"])
  end

  test do
    input = <<~EOS
      one two three
      … …… ………
      ... ...... .........
    EOS
    result = <<~EOS
      one  two     three
      …   ……    ………
      ...  ......  .........
    EOS
    assert_equal result, pipe_output("#{bin}/align -g2", input)
  end
end

__END__
--- a/CharWidth.xs
+++ b/CharWidth.xs
@@ -5,7 +5,12 @@
 #include "ppport.h"
 
 #include <wchar.h>
+#include "wcwidth9.h"
 
+int max(int a, int b) {
+	return a > b ? a : b;
+}
+
 MODULE = Text::CharWidth		PACKAGE = Text::CharWidth		
 
 int
@@ -17,7 +22,7 @@
 		r = mbstowcs(wstr, str, 1);
 		if (r == -1) RETVAL = -1;
 		else if (r == 0) RETVAL = 0;
-		else RETVAL = wcwidth(wstr[0]);
+		else RETVAL = max(wcwidth9(wstr[0]), 0);
 	OUTPUT:
 		RETVAL
 
@@ -33,7 +38,7 @@
 		while (*str != 0) {
 			r = mbstowcs(wstr, str, 1);
 			if (r == 0 || r == -1) {RETVAL = -1; break;}
-			RETVAL += wcwidth(wstr[0]);
+			RETVAL += max(wcwidth9(wstr[0]), 0);
 			len2 = mblen(str, len+1);
 			if (len2 <= 0) {RETVAL = -1; break;}
 			str += len2; len -= len2;
