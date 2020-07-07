class BusyboxManpage < Formula
  desc "Man page for Busybox"
  homepage "https://busybox.net/"
  url "https://busybox.net/downloads/busybox-1.32.0.tar.bz2"
  sha256 "c35d87f1d04b2b153d33c275c2632e40d388a88f19a9e71727e0bbbff51fe689"

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
