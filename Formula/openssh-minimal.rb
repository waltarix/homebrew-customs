class OpensshMinimal < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.8p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.8p1.tar.gz"
  version "9.8p1"
  sha256 "dd8bd002a379b5d499dfb050dd1fa9af8029e80461f4bb6c523c49973f5a39f3"
  license "SSH-OpenSSH"

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  conflicts_with "openssh", because: "both install the same binaries"

  depends_on "pkg-config" => :build
  depends_on "openssl@3"
  depends_on "zlib"

  def install
    args = *std_configure_args + %W[
      --sysconfdir=#{etc}/ssh
      --with-ssl-dir=#{Formula["openssl@3"].opt_prefix}
      --with-ssl-engine
      --without-ldns
      --without-libedit
      --without-kerberos5
      --without-pam
      --without-security-key-builtin
    ]

    args << "--with-privsep-path=#{var}/lib/sshd" if OS.linux?

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"
  end

  test do
    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    fork { exec sbin/"sshd", "-D", "-p", port.to_s }
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end
