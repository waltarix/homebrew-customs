class Jq < Formula
  desc "Lightweight and flexible command-line JSON processor"
  homepage "https://jqlang.github.io/jq/"
  url "https://github.com/waltarix/jq/releases/download/jq-1.8.2-custom/jq-1.8.2-custom.tar.xz"
  sha256 "91b7c2fbc4808b0d1a46764c5a7b827f26816828d84d457d3b4634408b8f23bd"
  license "MIT"

  depends_on "libtool" => :build
  depends_on "oniguruma" => :build
  depends_on "waltarix/customs/cmigemo" => :build

  on_macos do
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--enable-all-static",
                          "--with-oniguruma=#{Formula["oniguruma"].opt_prefix}",
                          "--with-migemo"
    system "make", "install"
  end

  test do
    assert_equal "2\n", pipe_output("#{bin}/jq .bar", '{"foo":1, "bar":2}')
    assert_equal "[\"ボブ\"]\n", pipe_output("#{bin}/jq -c 'map(select(test_migemo(\"bob\")))'", '["ボブ", "スー"]')
  end
end
