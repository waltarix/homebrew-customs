class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/waltarix/mosh/releases/download/mosh-1.4.0-custom-r6/mosh-1.4.0-custom.tar.xz"
  sha256 "72765e602803bb04caf7d8ef73e23cff2b60e0578de02cbc7bb0b5decbac3fc5"
  license "GPL-3.0-or-later"
  revision 13

  depends_on "pkg-config" => :build
  depends_on "ncurses"
  depends_on "openssl@3"
  depends_on "protobuf"
  depends_on "zstd"

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append_to_cflags "-flto"
    ENV.append_to_cflags "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "'#{bin}/mosh-client"

    args = %W[
      --prefix=#{prefix}
      --enable-completion
      --disable-silent-rules
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
