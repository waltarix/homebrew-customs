class Yj < Formula
  desc "Command line tool that converts YAML to JSON"
  homepage "https://github.com/bruceadams/yj"
  if OS.linux?
    url "https://github.com/waltarix/yj/releases/download/v1.2.2-custom/yj-1.2.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "706c7ecb1a813cd546b74a69fec7482c243c00479d18d801d80a0c6bef85f552"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/yj/releases/download/v1.2.2-custom/yj-1.2.2-aarch64-apple-darwin.tar.xz"
      sha256 "24fb99383abb81ba9c1abd222d15ebf6d9684f024a538aff27e87fa439b47ba9"
    else
      url "https://github.com/waltarix/yj/releases/download/v1.2.2-custom/yj-1.2.2-x86_64-apple-darwin.tar.xz"
      sha256 "ba674a1f3f3896fed58a1302a9330f8d10bcbf76180a2c2a2dc45da1650cb2f9"
    end
  end
  license "Apache-2.0"

  def install
    bin.install "yj"
  end

  test do
    assert_equal '{"foo":"bar"}', pipe_output("#{bin}/yj -c", "foo: bar")
  end
end

