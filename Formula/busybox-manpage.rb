class BusyboxManpage < Formula
  desc "Man page for Busybox"
  homepage "https://busybox.net/"
  url "https://busybox.net/downloads/busybox-1.36.0.tar.bz2"
  sha256 "542750c8af7cb2630e201780b4f99f3dcceeb06f505b479ec68241c1e6af61a5"
  license "GPL-2.0"

  livecheck do
    url :homepage
    regex(/BusyBox\s+(\d+(?:\.\d+)*)\s+\((?:un)?stable\)/i)
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
