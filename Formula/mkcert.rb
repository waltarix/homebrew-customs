class Mkcert < Formula
  desc "Simple tool to make locally trusted development certificates"
  homepage "https://github.com/FiloSottile/mkcert"
  if OS.linux?
    url "https://github.com/waltarix/mkcert/releases/download/v1.4.4-custom/mkcert-1.4.4-linux_amd64.tar.xz"
    sha256 "bf4adb2421c5e064b70eb356569cf030274a818ba51c6cd7609681a77117ace2"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/mkcert/releases/download/v1.4.4-custom/mkcert-1.4.4-darwin_arm64.tar.xz"
      sha256 "87c749b03e348a01bd7cd5325f76a150e98d86459e1c549e80d4ea8d4a04201f"
    else
      url "https://github.com/waltarix/mkcert/releases/download/v1.4.4-custom/mkcert-1.4.4-darwin_amd64.tar.xz"
      sha256 "6095a2e3790ce04deebba7b8774edbb89ea8396aff87fc64df2ccac35aefa4f0"
    end
  end
  version "1.4.4"
  license "BSD-3-Clause"

  def install
    bin.install "mkcert"
  end

  test do
    ENV["CAROOT"] = testpath
    system bin/"mkcert", "brew.test"
    assert_predicate testpath/"brew.test.pem", :exist?
    assert_predicate testpath/"brew.test-key.pem", :exist?
    output = (testpath/"brew.test.pem").read
    assert_match "-----BEGIN CERTIFICATE-----", output
    output = (testpath/"brew.test-key.pem").read
    assert_match "-----BEGIN PRIVATE KEY-----", output
  end
end
