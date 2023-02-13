class Assh < Formula
  desc "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts"
  homepage "https://manfred.life/assh"
  if OS.linux?
    url "https://github.com/waltarix/assh/releases/download/v2.14.0-custom/assh-2.14.0-linux_amd64.tar.xz"
    sha256 "d91ed6fd8326dff19ed7fcedd11c779df1086538cf1fc59b8df93ae1579fb838"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/assh/releases/download/v2.14.0-custom/assh-2.14.0-darwin_arm64.tar.xz"
      sha256 "57a6c5e86f3b9c22d7fef525e89d16f63fe6f237082d7fb4bfa0bd5588db1224"
    else
      url "https://github.com/waltarix/assh/releases/download/v2.14.0-custom/assh-2.14.0-darwin_amd64.tar.xz"
      sha256 "bf60b1616371a1f0c926722633ac83bc26f7ae8b98fae02d4cfe8fe319fc2221"
    end
  end
  version "2.14.0"
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
