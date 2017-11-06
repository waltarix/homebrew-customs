class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://packages.debian.org/source/stable/sl"
  url "https://mirrors.kernel.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/s/sl/sl_3.03.orig.tar.gz"
  sha256 "5986d9d47ea5e812d0cbd54a0fc20f127a02d13b45469bb51ec63856a5a6d3aa"

  fails_with :clang do
    build 318
  end

  patch :p1 do
    url "https://raw.githubusercontent.com/euank/docker-sl/master/sl5-1.patch"
    sha256 "4943b6f000f518ed08755b36d9b753291989c4867e55d74bc4cc4502f6e9422f"
  end

  def install
    inreplace "Makefile", "-DLINUX20 ", ""

    system "make", "-e"
    bin.install "sl"
    man1.install "sl.1"
  end

  test do
    assert_equal "#{bin}/sl", shell_output("which sl").chomp
  end
end
