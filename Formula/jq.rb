class Jq < Formula
  desc "Lightweight and flexible command-line JSON processor"
  homepage "https://stedolan.github.io/jq/"
  url "https://github.com/waltarix/jq.git",
    revision: "28bb5ff6ca78bf4b92462a895270746214efaf89"
  version "1.6-152-gcff5336"
  license "MIT"
  revision 1

  depends_on "libtool" => :build
  depends_on "oniguruma" => :build
  depends_on "waltarix/customs/cmigemo" => :build

  on_macos do
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    (buildpath/"scripts/version").write_env_script("echo", version, {})

    system "autoreconf", "-iv"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-maintainer-mode",
                          "--enable-all-static",
                          "--with-oniguruma=#{Formula["oniguruma"].opt_prefix}",
                          "--with-migemo",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_equal "2\n", pipe_output("#{bin}/jq .bar", '{"foo":1, "bar":2}')
    assert_equal "[\"ボブ\"]\n", pipe_output("#{bin}/jq -c 'map(select(test_migemo(\"bob\")))'", '["ボブ", "スー"]')
  end
end
