class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.0.0-beta-custom/mlr-6.0.0-linux_amd64.tar.xz"
    sha256 "e869d557eab088e11cf1e72e44c8b9ef758af2fee14089b1c11dac16b2961d3b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.0.0-beta-custom/mlr-6.0.0-darwin_arm64.tar.xz"
      sha256 "b79bdc0381f7742c270836a9514e99167ecbefa91953bd17c8ea610a91311af6"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.0.0-beta-custom/mlr-6.0.0-darwin_amd64.tar.xz"
      sha256 "5b65c59ea2ebfdfb22a3c457fcdd5fae9d79a03464085d6db5cb932ef4a4affc"
    end
  end
  version "6.0.0-beta"
  license "BSD-2-Clause"

  def install
    bin.install "mlr"
  end

  test do
    (testpath/"test.csv").write <<~EOS
      one,two,three
      …,……,………
      ...,......,.........
    EOS
    result = <<~EOS
      ╭─────┬────────┬───────────╮
      │ one │ two    │ three     │
      ├─────┼────────┼───────────┤
      │ …  │ ……   │ ………    │
      │ ... │ ...... │ ......... │
      ╰─────┴────────┴───────────╯
    EOS
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_equal result, pipe_output("#{bin}/mlr --c2p --barred cat test.csv")
  end
end
