class Cmigemo < Formula
  desc "Migemo is a tool that supports Japanese incremental search with Romaji"
  homepage "https://www.kaoriya.net/software/cmigemo"
  url "https://github.com/waltarix/cmigemo.git",
    :tag => "20150404-custom-r3"
  version "20150404-custom-r3"

  depends_on "nkf" => :build

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", make_target
    system "make", "#{make_target}-dict"
    ENV.deparallelize # Install can fail on multi-core machines unless serialized
    system "make", "#{make_target}-install"
  end

  def caveats
    <<~EOS
      See also https://github.com/emacs-jp/migemo to use cmigemo with Emacs.
      You will have to save as migemo.el and put it in your load-path.
    EOS
  end

  def make_target
    return "gcc" if OS.linux?

    "osx"
  end

  test do
    assert_match "ほげ", shell_output("#{bin}/cmigemo -w hoge")
  end
end
