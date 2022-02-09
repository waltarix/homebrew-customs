class Pspg < Formula
  desc "Unix pager optimized for psql"
  homepage "https://github.com/okbob/pspg"
  url "https://github.com/okbob/pspg/archive/5.5.3.tar.gz"
  sha256 "c5360f42af5f87f07c8cb894b2da622685d1d800022cf9d22bfa37f3f918447b"
  license "BSD-2-Clause"
  head "https://github.com/okbob/pspg.git", branch: "master"

  depends_on "libpq"
  depends_on "ncurses"
  depends_on "readline"

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/14.0.0-r2/wcwidth9.h"
    sha256 "8ce9e402611a0f8c2a44130571d9043144d43463893e13a6459d0b2c22b67eb2"
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
