class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://manfred.life/assh"
  if OS.linux?
    url "https://github.com/waltarix/assh/releases/download/v2.11.0-custom-r1/assh-2.11.0-linux_amd64.tar.xz"
    sha256 "dd41da7754a071ddf08b3020f5b5dd7a9d949da92affc5de28edff763265421b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/assh/releases/download/v2.11.0-custom-r1/assh-2.11.0-darwin_arm64.tar.xz"
      sha256 "f8ce5207fdeac2136287199664f6e3218df8e3d219d2eec8e646772e5632645d"
    else
      url "https://github.com/waltarix/assh/releases/download/v2.11.0-custom-r1/assh-2.11.0-darwin_amd64.tar.xz"
      sha256 "974efddfb8d3a905fb48458a853e2c8f7032cfb9621babb256a659f6d67d7dd0"
    end
  end
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
