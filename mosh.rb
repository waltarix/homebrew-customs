class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/waltarix/mosh/releases/download/mosh-1.4.0-custom-r3/mosh-1.4.0-custom.tar.xz"
  sha256 "7adda46edfc4107e581e1dce386fde1c02a7ffe5df5e85fa4f40dc55ff343eab"
  license "GPL-3.0-or-later"
  revision 3

  livecheck do
    url :homepage
    regex(/href=.*?mosh[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "ncurses"
  depends_on "openssl@3"
  depends_on "protobuf"
  depends_on "zstd"

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    ENV.cxx11

    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    args = %W[
      --prefix=#{prefix}
      --enable-completion
      --enable-syslog
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
