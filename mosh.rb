class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/waltarix/mosh/releases/download/mosh-1.3.2-custom-r8/mosh-1.3.2-custom.tar.xz"
  sha256 "2e3410051902bafd931510e1d49ad9eb92d02607b7bb8ecb14caa55267e74304"
  license "GPL-3.0-or-later"
  revision 27

  livecheck do
    url :homepage
    regex(/href=.*?mosh[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "ncurses"
  depends_on "openssl@1.1"
  depends_on "protobuf"
  depends_on "zlib"

  def install
    ENV.cxx11

    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    args = %W[
      --prefix=#{prefix}
      --enable-completion
      --with-crypto-library=openssl-with-openssl-ocb
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
