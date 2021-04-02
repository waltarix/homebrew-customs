class UniversalCtagsDebian < Formula
  desc "Maintained ctags implementation"
  homepage "https://packages.debian.org/sid/universal-ctags"
  url "https://deb.debian.org/debian/pool/main/u/universal-ctags/universal-ctags_0+git20200824.orig.tar.gz"
  version "0+git20200824-1"
  sha256 "d2e851f5c51744c4e175200bc1ac7a2e9cab18aa6b9f8aabdffeacdf8324b94d"

  if OS.mac?
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end
  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "jansson"
  depends_on "libxml2"
  depends_on "libyaml"

  conflicts_with "ctags", because: "this formula installs the same executable as the ctags formula"

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  def caveats
    <<~EOS
      Under some circumstances, emacs and ctags can conflict. By default,
      emacs provides an executable `ctags` that would conflict with the
      executable of the same name that ctags provides. To prevent this,
      Homebrew removes the emacs `ctags` and its manpage before linking.
      However, if you install emacs with the `--keep-ctags` option, then
      the `ctags` emacs provides will not be removed. In that case, you
      won't be able to install ctags successfully. It will build but not
      link.
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>

      void func()
      {
        printf("Hello World!");
      }

      int main()
      {
        func();
        return 0;
      }
    EOS
    system "#{bin}/ctags", "-R", "."
    assert_match(/func.*test\.c/, File.read("tags"))

    path = testpath/"test.txt"
    path.write <<~EOS
      {"command":"generate-tags", "filename":"test.rb", "size": 17}
      def foobaz() end
    EOS
    expected = <<~EOS
      {"_type": "program", "name": "Universal Ctags", "version": "0.0.0"}
      {"_type": "tag", "name": "foobaz", "path": "test.rb", "pattern": "/^def foobaz() end$/", "kind": "method"}
      {"_type": "completed", "command": "generate-tags"}
    EOS
    result = shell_output("#{bin}/ctags --_interactive < #{path}")
    assert_equal expected, result
  end
end
