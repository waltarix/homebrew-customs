class Jsonxf < Formula
  desc "A fast JSON pretty-printer and minimizer"
  homepage "https://github.com/gamache/jsonxf"
  if OS.linux?
    url "https://github.com/waltarix/jsonxf/releases/download/1.1.1-custom/jsonxf-1.1.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "67964207225bce92fb68019700479cbdc1f9dee39afdf1aeee2775947fec3391"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/jsonxf/releases/download/1.1.1-custom/jsonxf-1.1.1-aarch64-apple-darwin.tar.xz"
      sha256 "fab311f932fd5bf20f10483df19e839092dca5bfa4f66186bbd411053c1c8541"
    else
      url "https://github.com/waltarix/jsonxf/releases/download/1.1.1-custom/jsonxf-1.1.1-x86_64-apple-darwin.tar.xz"
      sha256 "13dd82f28d5f18b5b4eee05e38b8bd829c9cdfe4f575379657afe5c1abe1e6d8"
    end
  end
  license "MIT"

  def install
    bin.install "jsonxf"
  end

  test do
    expected = <<~EOS
      {
        "foo": "bar",
        "baz": "qux"
      }
    EOS
    assert_equal expected, pipe_output(bin/"jsonxf", '{"foo":"bar","baz":"qux"}')
  end
end
