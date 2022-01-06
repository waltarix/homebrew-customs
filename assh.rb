class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://manfred.life/assh"
  if OS.linux?
    url "https://github.com/waltarix/assh/releases/download/v2.12.2-custom/assh-2.12.2-linux_amd64.tar.xz"
    sha256 "d01700ce8d64cdb1da8d786cb980c0af2865f2aae031fe1a82a950f84fa28678"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/assh/releases/download/v2.12.2-custom/assh-2.12.2-darwin_arm64.tar.xz"
      sha256 "5db813f545a7c0206a0ce0424981a99e9cb6a0d2fd96bd9adaac4f875d2a9961"
    else
      url "https://github.com/waltarix/assh/releases/download/v2.12.2-custom/assh-2.12.2-darwin_amd64.tar.xz"
      sha256 "405f8d21bd8614cd2a24a9a170df796e63034da5cefd2d2c6d452473b19992e8"
    end
  end
  version "2.12.2"
  license "MIT"

  def install
    bin.install "assh"
  end

  test do
    assh_config = testpath/"assh.yml"
    assh_config.write <<~EOS
      hosts:
        hosta:
          Hostname: 127.0.0.1
      asshknownhostfile: /dev/null
    EOS

    output = "hosta assh ping statistics"
    assert_match output, shell_output("#{bin}/assh --config #{assh_config} ping -c 4 hosta 2>&1")
  end
end
