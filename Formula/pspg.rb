class Pspg < Formula
  desc "Unix pager optimized for psql"
  homepage "https://github.com/okbob/pspg"
  url "https://github.com/okbob/pspg/archive/refs/tags/5.8.6.tar.gz"
  sha256 "ed7c1d43c813b2415d5ce0099ae34381c10f82f211de10a4d8ed0ffcf4f2a938"
  license "BSD-2-Clause"
  head "https://github.com/okbob/pspg.git", branch: "master"

  depends_on "libpq"
  depends_on "ncurses"
  depends_on "readline"

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.1.0-r1/wcwidth9.h"
    sha256 "5afe09e6986233b517c05e4c82dbb228bb6ed64ba4be6fd7bf3185b7d3e72eb0"
  end

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append_to_cflags "-flto"
    ENV.append_to_cflags "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    resource("wcwidth9.h").stage(buildpath/"src")
    inreplace "src/unicode.c", /(?<=^#include <string\.h>)/, %(\n#include "wcwidth9.h")
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
