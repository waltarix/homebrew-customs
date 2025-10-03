class OpensshMinimal < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p2.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p2.tar.gz"
  version "10.0p2"
  sha256 "021a2e709a0edf4250b1256bd5a9e500411a90dddabea830ed59cef90eb9d85c"
  license "SSH-OpenSSH"

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  conflicts_with "openssh", because: "both install the same binaries"

  depends_on "pkgconf" => :build
  depends_on "openssl@3"
  depends_on "zlib"

  def install
    args = %W[
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

    system "./configure", *args, *std_configure_args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"

    # Don't hardcode Cellar paths in configuration files
    # inreplace etc/"ssh/sshd_config", prefix, opt_prefix
  end

  test do
    # (etc/"ssh").find do |pn|
    #   next unless pn.file?
    #
    #   refute_match HOMEBREW_CELLAR.to_s, pn.read
    # end

    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    spawn sbin/"sshd", "-D", "-p", port.to_s
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end
