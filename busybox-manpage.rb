class BusyboxManpage < Formula
  desc "Man page for Busybox"
  homepage "https://busybox.net/"
  url "https://busybox.net/downloads/busybox-1.35.0.tar.bz2"
  sha256 "faeeb244c35a348a334f4a59e44626ee870fb07b6884d68c10ae8bc19f83a694"
  license "GPL-2.0"

  livecheck do
    url :homepage
    regex(/BusyBox\s+(\d+(?:\.\d+)*)\s+\(stable\)/i)
  end

  on_macos do
    depends_on "gnu-sed" => :build
  end

  def install
    system "make", "defconfig"
    system "make", "doc"

    man1.install "docs/busybox.1"
  end

  test do
    system "man", "-d", "busybox"
  end
end
