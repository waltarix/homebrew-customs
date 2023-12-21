class Jq < Formula
  desc "Lightweight and flexible command-line JSON processor"
  homepage "https://jqlang.github.io/jq/"
  url "https://github.com/waltarix/jq/releases/download/jq-1.7.1-custom/jq-1.7.1-custom.tar.xz"
  sha256 "ec03f78f33827d26151f79d58ade32761f1a429ff99c41edf86016ac1a83464a"
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
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    (buildpath/"scripts/version").write_env_script("echo", version, {})

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
