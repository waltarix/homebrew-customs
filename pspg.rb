class Pspg < Formula
  desc "Unix pager optimized for psql"
  homepage "https://github.com/okbob/pspg"
  url "https://github.com/okbob/pspg/archive/5.5.8.tar.gz"
  sha256 "bc25e517784f08840796188d1fb8e908ed522d0809c0ca176eae07363bd5281b"
  license "BSD-2-Clause"
  head "https://github.com/okbob/pspg.git", branch: "master"

  depends_on "libpq"
  depends_on "ncurses"
  depends_on "readline"

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.0.0/wcwidth9.h"
    sha256 "a18bd4ddc6a27e9f7a9c9ba273bf3a120846f31fe32f00972aa7987d21e3154d"
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
