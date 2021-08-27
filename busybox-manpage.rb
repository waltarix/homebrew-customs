class BusyboxManpage < Formula
  desc "Man page for Busybox"
  homepage "https://busybox.net/"
  url "https://busybox.net/downloads/busybox-1.33.1.tar.bz2"
  sha256 "12cec6bd2b16d8a9446dd16130f2b92982f1819f6e1c5f5887b6db03f5660d28"
  license "GPL-2.0"

  livecheck do
    url :homepage
    regex(/BusyBox\s+(\d+(?:\.\d+)*)\s+\(stable\)/i)
  end

  depends_on "gnu-sed" => :build

  def install
    system "make", "defconfig"
    system "make", "doc"

    man1.install "docs/busybox.1"
  end

  test do
    system "man", "-d", "busybox"
  end
end
