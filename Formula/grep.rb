class Grep < Formula
  desc "GNU grep, egrep and fgrep"
  homepage "https://www.gnu.org/software/grep/"
  url "https://ftp.gnu.org/gnu/grep/grep-3.8.tar.xz"
  mirror "https://ftpmirror.gnu.org/grep/grep-3.8.tar.xz"
  sha256 "498d7cc1b4fb081904d87343febb73475cf771e424fb7e6141aff66013abc382"
  license "GPL-3.0-or-later"

  depends_on "pkg-config" => :build
  depends_on "pcre2"

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-nls
      --prefix=#{prefix}
      --infodir=#{info}
      --mandir=#{man}
      --with-packager=Homebrew
    ]

    args << "--program-prefix=g" if OS.mac?
    system "./configure", *args
    system "make"
    system "make", "install"

    if OS.mac?
      %w[grep egrep fgrep].each do |prog|
        prog_bin = bin/"g#{prog}"
        prog_man = man1/"g#{prog}.1"
        (libexec/"gnubin").install_symlink prog_bin => prog
        (libexec/"gnuman/man1").install_symlink prog_man => "#{prog}.1" if prog_man.exist?
      end
    end

    libexec.install_symlink "gnuman" => "man"
  end

  def caveats
    on_macos do
      <<~EOS
        All commands have been installed with the prefix "g".
        If you need to use these commands with their normal names, you
        can add a "gnubin" directory to your PATH from your bashrc like:
          PATH="#{opt_libexec}/gnubin:$PATH"
      EOS
    end
  end

  test do
    text_file = testpath/"file.txt"
    text_file.write "This line should be matched"

    if OS.mac?
      grepped = shell_output("#{bin}/ggrep match #{text_file}")
      assert_match "should be matched", grepped

      grepped = shell_output("#{opt_libexec}/gnubin/grep match #{text_file}")
    else
      grepped = shell_output("#{bin}/grep match #{text_file}")
    end
    assert_match "should be matched", grepped
  end
end
