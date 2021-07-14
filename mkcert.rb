class Mkcert < Formula
  desc "Simple tool to make locally trusted development certificates"
  homepage "https://github.com/FiloSottile/mkcert"
  if OS.linux?
    url "https://github.com/waltarix/mkcert/releases/download/v1.4.3-custom/mkcert-1.4.3-linux_amd64.tar.xz"
    sha256 "f5696b0b73d8a6fff602678e82c47efdf12289e6f04ef07250850c5917a88232"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/mkcert/releases/download/v1.4.3-custom/mkcert-1.4.3-darwin_arm64.tar.xz"
      sha256 "6f3cb63e553fb4e1338aa5bc77df344982c5991a14f1f3b7bae66078c3baff92"
    else
      url "https://github.com/waltarix/mkcert/releases/download/v1.4.3-custom/mkcert-1.4.3-darwin_amd64.tar.xz"
      sha256 "16b99eb6021fcf9a9ea338167a7443671df8c69021cc469bda059b291a6a2879"
    end
  end
  version "1.4.3"
  license "BSD-3-Clause"

  bottle :unneeded

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
