class QuicsshRs < Formula
  desc "QUIC proxy that allows to use QUIC to connect to an SSH server"
  homepage "https://github.com/oowl/quicssh-rs"
  "0.1.5".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/quicssh-rs/releases/download/v#{v}-custom/quicssh-rs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "4cd6e3a2b4c2014275477951f546c7cf11d96eddad7c47584614a29a0c368815"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/quicssh-rs/releases/download/v#{v}-custom/quicssh-rs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "5b0480cbcf75efd8d97253d7da2e9df860aac78ebfc23ac7d4912bb62796d633"
      else
        url "https://github.com/waltarix/quicssh-rs/releases/download/v#{v}-custom/quicssh-rs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "f446c110567c440b3962efb8cd027ee3cc0dae2ccf4cbebbad875aab0d09f8c5"
      end
    end
  end
  license "MIT"

  def install
    bin.install "quicssh-rs"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/quicssh-rs --version")
  end
end
