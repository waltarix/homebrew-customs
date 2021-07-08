class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://manfred.life/assh"
  if OS.linux?
    url "https://github.com/waltarix/assh/releases/download/v2.11.3-custom/assh-2.11.3-linux_amd64.tar.xz"
    sha256 "081d3a32b01f8106171d50f9ec41adf446d672f535c9159aa016845cbecaef8e"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/assh/releases/download/v2.11.3-custom/assh-2.11.3-darwin_arm64.tar.xz"
      sha256 "7808db876ba989c4b7fca591552fc999a7bc9a36a1806c6ee84b5c23368fe33f"
    else
      url "https://github.com/waltarix/assh/releases/download/v2.11.3-custom/assh-2.11.3-darwin_amd64.tar.xz"
      sha256 "c6bd8cfffd5f5dcf14c882bf605e66bcdb9fae19c19465a021e61dca9f84361b"
    end
  end
  version "2.11.3"
  license "MIT"

  bottle :unneeded

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
