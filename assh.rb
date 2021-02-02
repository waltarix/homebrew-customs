class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://manfred.life/assh"
  if OS.linux?
    url "https://github.com/waltarix/assh/releases/download/v2.11.0-custom-r2/assh-2.11.0-linux_amd64.tar.xz"
    sha256 "ffeee53ac56c0c919c4c0862f9c26cf01902c6dcabfb59f04984637ddb2f3275"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/assh/releases/download/v2.11.0-custom-r2/assh-2.11.0-darwin_arm64.tar.xz"
      sha256 "89ae8c6b0623a0aef25368e60fdd2ee55ffc83c9ff3d0b5a6a096c42a512b40e"
    else
      url "https://github.com/waltarix/assh/releases/download/v2.11.0-custom-r2/assh-2.11.0-darwin_amd64.tar.xz"
      sha256 "78afeb6f83b9ff74c071a10682254f200bc90cd91e109ea0d5910e9b935c535c"
    end
  end
  version "2.11.0"
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
