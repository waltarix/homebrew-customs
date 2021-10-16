class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://manfred.life/assh"
  if OS.linux?
    url "https://github.com/waltarix/assh/releases/download/v2.12.0-custom/assh-2.12.0-linux_amd64.tar.xz"
    sha256 "37d4bb7ba9c9dcbb83ca595d4147caf6d60992acc7d3d7f23169e133b81ec815"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/assh/releases/download/v2.12.0-custom/assh-2.12.0-darwin_arm64.tar.xz"
      sha256 "3252f78708445e90d0826972b55b1f27c200865e9ff75616a1314511b2f302ac"
    else
      url "https://github.com/waltarix/assh/releases/download/v2.12.0-custom/assh-2.12.0-darwin_amd64.tar.xz"
      sha256 "74f8a765a51edbafbbaadeef4555475aad2fe1c031693b90051612aa820f3206"
    end
  end
  version "2.12.0"
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
