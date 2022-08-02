class Pspg < Formula
  desc "Unix pager optimized for psql"
  homepage "https://github.com/okbob/pspg"
  url "https://github.com/okbob/pspg/archive/5.5.6.tar.gz"
  sha256 "220417b9b1adb9e512ee66c44f655c179cfb66ec53fc7f252e3e1c75ac77c884"
  license "BSD-2-Clause"
  head "https://github.com/okbob/pspg.git", branch: "master"

  depends_on "libpq"
  depends_on "ncurses"
  depends_on "readline"

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/14.0.0-r3/wcwidth9.h"
    sha256 "5797b11ba5712a6a98ad21ed2a2cec71467e2ccd4b0c7fd43ebb16a00ff85bda"
  end

  def install
    resource("wcwidth9.h").stage(buildpath/"src")
    inreplace "src/unicode.c", /(?<=^#include "string\.h")/, %(\n#include "wcwidth9.h")
    inreplace "src/unicode.c", /(?<=return )ucs_wcwidth/, "wcwidth9"

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-ncursesw"
    system "make", "install"
  end

  def caveats
    <<~EOS
      Add the following line to your psql profile (e.g. ~/.psqlrc)
        \\setenv PAGER pspg
        \\pset border 2
        \\pset linestyle unicode
    EOS
  end

  test do
    assert_match "pspg-#{version}", shell_output("#{bin}/pspg --version")
  end
end
