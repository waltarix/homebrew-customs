class Mosh < Formula
  desc "Remote terminal application"
  homepage "https://mosh.org"
  url "https://github.com/waltarix/mosh/releases/download/mosh-1.3.2-custom-r5/mosh-1.3.2-custom.tar.xz"
  sha256 "9c54b875d3c619c24808cbde5eb3ec91e898f426552dea1b0a8cca8fc64e41a8"
  license "GPL-3.0-or-later"
  revision 23

  depends_on "pkg-config" => :build
  depends_on "protobuf"

  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  on_linux do
    depends_on "openssl@1.1" # Uses CommonCrypto on macOS
  end

  def install
    ENV.cxx11

    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    args = %W[
      --prefix=#{prefix}
      --enable-completion
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
