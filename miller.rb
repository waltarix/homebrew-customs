class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v5.10.0-custom/mlr-5.10.0-linux_amd64.tar.xz"
    sha256 "ef18e1c822dfd5af91214f50f639d8da09fda160899fb5ebe292528baf89d927"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v5.10.0-custom/mlr-5.10.0-darwin_arm64.tar.xz"
      sha256 "c7f01d44443a1e76ab0c7bfcc3b272cb584dc421cd56a4da76dee3e822e5fc1b"
    else
      url "https://github.com/waltarix/miller/releases/download/v5.10.0-custom/mlr-5.10.0-darwin_amd64.tar.xz"
      sha256 "3e39189da2fc8d5bed5cb38160b5b0e7eedd1e271db3898d406f5e6a31c432d8"
    end
  end
  version "5.10.0"
  license "BSD-2-Clause"

  bottle :unneeded

  def install
    bin.install ["mlr", "gmlr"]
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
    assert_equal result, pipe_output("#{bin}/gmlr --c2p --barred cat test.csv")
  end
end
