class BusyboxManpage < Formula
  desc "Man page for Busybox"
  homepage "https://busybox.net/"
  url "https://busybox.net/downloads/busybox-1.31.0.tar.bz2"
  sha256 "0e4925392fd9f3743cc517e031b68b012b24a63b0cf6c1ff03cce7bb3846cc99"

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
