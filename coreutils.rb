class Coreutils < Formula
  desc "GNU File, Shell, and Text utilities"
  homepage "https://www.gnu.org/software/coreutils"
  url "https://ftpmirror.gnu.org/coreutils/coreutils-8.27.tar.xz"
  mirror "https://ftp.gnu.org/gnu/coreutils/coreutils-8.27.tar.xz"
  sha256 "8891d349ee87b9ff7870f52b6d9312a9db672d2439d289bc57084771ca21656b"

  bottle do
    sha256 "a951d21ffbf3407ca84356d369ed6009d248b263587b79f644d9a95300465fa6" => :sierra
    sha256 "dafd72ff298ed109503928a3d7cf1623327b4bc65318e99b48f3415b7c469ac8" => :el_capitan
    sha256 "5d636c1ad28b1ef25c140b1486fdb368486bcca563901ad543d62ce1bd5f8b70" => :yosemite
  end

  head do
    url "https://git.savannah.gnu.org/git/coreutils.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "gettext" => :build
    depends_on "texinfo" => :build
    depends_on "xz" => :build
    depends_on "wget" => :build
  end

  depends_on "gmp" => :optional

  conflicts_with "ganglia", :because => "both install `gstat` binaries"
  conflicts_with "idutils", :because => "both install `gid` and `gid.1`"
  conflicts_with "aardvark_shell_utils", :because => "both install `realpath` binaries"

  def pour_bottle?
    false
  end

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1408362/raw/0b8c487946b83a106af861b524ff4f42565b2989/coreutils-ls-utf8mac.patch"
    sha256 "1e9fb1fc5ad65ed38de833b068ad726f23d6d5a9d529030a78bbd7a2e15b7a36"
  end

  def install
    # Work around unremovable, nested dirs bug that affects lots of
    # GNU projects. See:
    # https://github.com/Homebrew/homebrew/issues/45273
    # https://github.com/Homebrew/homebrew/issues/44993
    # This is thought to be an el_capitan bug:
    # https://lists.gnu.org/archive/html/bug-tar/2015-10/msg00017.html
    if MacOS.version == :el_capitan
      ENV["gl_cv_func_getcwd_abort_bug"] = "no"
    end

    system "./bootstrap" if build.head?
    args = %W[
      --prefix=#{prefix}
      --program-prefix=g
    ]
    args << "--without-gmp" if build.without? "gmp"
    system "./configure", *args
    system "make", "install"

    # Symlink all commands into libexec/gnubin without the 'g' prefix
    coreutils_filenames(bin).each do |cmd|
      (libexec/"gnubin").install_symlink bin/"g#{cmd}" => cmd
    end
    # Symlink all man(1) pages into libexec/gnuman without the 'g' prefix
    coreutils_filenames(man1).each do |cmd|
      (libexec/"gnuman"/"man1").install_symlink man1/"g#{cmd}" => cmd
    end

    # Symlink non-conflicting binaries
    bin.install_symlink "grealpath" => "realpath"
    man1.install_symlink "grealpath.1" => "realpath.1"
  end

  def caveats; <<-EOS.undent
    All commands have been installed with the prefix 'g'.

    If you really need to use these commands with their normal names, you
    can add a "gnubin" directory to your PATH from your bashrc like:

        PATH="#{opt_libexec}/gnubin:$PATH"

    Additionally, you can access their man pages with normal names if you add
    the "gnuman" directory to your MANPATH from your bashrc as well:

        MANPATH="#{opt_libexec}/gnuman:$MANPATH"

    EOS
  end

  def coreutils_filenames(dir)
    filenames = []
    dir.find do |path|
      next if path.directory? || path.basename.to_s == ".DS_Store"
      filenames << path.basename.to_s.sub(/^g/, "")
    end
    filenames.sort
  end

  test do
    (testpath/"test").write("test")
    (testpath/"test.sha1").write("a94a8fe5ccb19ba61c4c0873d391e987982fbbd3 test")
    system "#{bin}/gsha1sum", "-c", "test.sha1"
  end
end
