class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  ["1.4.1", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/choose/releases/download/v#{v}-custom#{rev}/choose-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "b53371e239b2f9a07b7686badfc5a9bc3c676fc79c84c5700d5393f0137ae41a"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/choose/releases/download/v#{v}-custom#{rev}/choose-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "24dd58b9dc6ec291bcc0430f7daae59d3f36dc4782e94a921593716ef72dcadc"
      else
        url "https://github.com/waltarix/choose/releases/download/v#{v}-custom#{rev}/choose-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "fb7e22d70c6a2622576006082ee50551613ba9925c2f8c3d59651713bdbae0e4"
      end
    end
    revision r if r
  end
  license "GPL-3.0-or-later"

  conflicts_with "choose-gui", because: "both install a `choose` binary"
  conflicts_with "choose-rust", because: "both install a `choose` binary"

  def install
    bin.install "choose"

    generate_completions_from_executable(bin/"choose", "--completion")

    (man1/"choose.1").write Utils.safe_popen_read(bin/"choose", "--manpage")
  end

  test do
    input = "foo,  foobar,bar, baz"
    assert_equal "foobar bar", pipe_output("#{bin}/choose -f ',\\s*' 2:3", input).strip
  end
end
