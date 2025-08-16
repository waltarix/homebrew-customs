class Cmigemo < Formula
  desc "Migemo is a tool that supports Japanese incremental search with Romaji"
  homepage "https://www.kaoriya.net/software/cmigemo"
  url "https://github.com/waltarix/cmigemo.git",
    tag: "20220623-custom-r1"
  version "20220623-custom"
  license "MIT"
  revision 1

  depends_on "nkf" => :build

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"

    system "./configure", "--prefix=#{prefix}"

    os = OS.mac? ? "osx" : "gcc"
    system "make", os
    system "make", "#{os}-dict"
    system "make", "#{os}-install"
  end

  def caveats
    <<~EOS
      See also https://github.com/emacs-jp/migemo to use cmigemo with Emacs.
      You will have to save as migemo.el and put it in your load-path.
    EOS
  end

  test do
    assert_match "ほげ", shell_output("#{bin}/cmigemo -w hoge")
  end
end
