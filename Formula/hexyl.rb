class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.12.0-custom/hexyl-0.12.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "b119405a193bb65c9204638ce8f8aee640b681ad3b6791f2b799c9ced4e9bc4a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/hexyl/releases/download/v0.12.0-custom/hexyl-0.12.0-aarch64-apple-darwin.tar.xz"
      sha256 "1512ca949f1fd825fd72fa927652ac729d85bd5aa46379da9789f1a702eb2bbf"
    else
      url "https://github.com/waltarix/hexyl/releases/download/v0.12.0-custom/hexyl-0.12.0-x86_64-apple-darwin.tar.xz"
      sha256 "6ed018cb535edb8409d8276f6cd6e7df9ff8d12760228f8ed3bbf04a8f042ecb"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

  def install
    bin.install "hexyl"
    man1.install "manual/hexyl.1"

    generate_completions_from_executable(bin/"hexyl", "--completion")
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end
