class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/waltarix/mosh/releases/download/mosh-1.3.2-custom-r6/mosh-1.3.2-custom.tar.xz"
  sha256 "471743060a616c5dbdeb291c4c9755f7a566507e2ffbde7e0c10d3c355b353cb"
  license "GPL-3.0-or-later"
  revision 24

  depends_on "pkg-config" => :build
  depends_on "ncurses"
  depends_on "openssl@1.1"
  depends_on "protobuf"
  depends_on "zlib"

  def install
    ENV.cxx11

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    args = %W[
      --prefix=#{prefix}
      --enable-completion
      --with-crypto-library=openssl
      --with-external-ocb
    ]

    on_linux do
      args << "--with-utempter"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"mosh-client", "-c"
  end
end
