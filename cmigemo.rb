class Cmigemo < Formula
  desc "Migemo is a tool that supports Japanese incremental search with Romaji"
  homepage "https://www.kaoriya.net/software/cmigemo"
  url "https://github.com/koron/cmigemo.git",
    :revision => "5c014a885972c77e67d0d17d367d05017c5873f7"
  version "20150404"

  depends_on "nkf" => :build

  def install
    chmod 0755, "./configure"
    system "./configure", "--prefix=#{prefix}"
    system "make", make_target
    system "make", "#{make_target}-dict"
    system "make", "-C", "dict", "utf-8" if build.stable?
    ENV.deparallelize # Install can fail on multi-core machines unless serialized
    system "make", "#{make_target}-install"
  end

  def caveats; <<-EOS.undent
    See also https://github.com/emacs-jp/migemo to use cmigemo with Emacs.
    You will have to save as migemo.el and put it in your load-path.
    EOS
  end

  def make_target
    return "gcc" if OS.linux?

    "osx"
  end

  test do
    system "#{bin}/et", "--help"
  end
end
