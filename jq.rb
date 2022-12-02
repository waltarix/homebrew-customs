class Jq < Formula
  desc "Lightweight and flexible command-line JSON processor"
  homepage "https://stedolan.github.io/jq/"
  url "https://github.com/stedolan/jq.git",
      revision: "cff5336ec71b6fee396a95bb0e4bea365e0cd1e8"
  version "1.6-152-gcff5336"
  license "MIT"

  depends_on "libtool" => :build
  depends_on "oniguruma"

  on_macos do
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    inreplace "src/jv_print.c" do |s|
      colors = [
        "4;38;5;250", # null
        "0;38;5;219", # false
        "0;38;5;219", # true
        "0;33",       # numbers
        "0;38;5;214", # strings
        "0;36",       # arrays
        "0;38;5;119", # objects
      ].map do |v|
        %(COL("#{v}"))
      end.join(",")

      s.gsub!(/(?<=def_colors\[\] =).+?\};/m, "{#{colors}};")
      s.gsub!(/(?<=FIELD_COLOR COL\(")[^"]+/, "0;38;5;229")
    end

    (buildpath/"scripts/version").write_env_script("echo", version, {})

    system "autoreconf", "-iv"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-maintainer-mode",
                          "--enable-all-static",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_equal "2\n", pipe_output("#{bin}/jq .bar", '{"foo":1, "bar":2}')
  end
end
