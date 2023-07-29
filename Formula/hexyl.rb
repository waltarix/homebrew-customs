class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  "0.13.1".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/hexyl/releases/download/v#{v}-custom/hexyl-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "42543ba5529b399a053077d5b36dcec79af08801470c6a9ae841c7b6bcd3a429"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/hexyl/releases/download/v#{v}-custom/hexyl-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "d6ea2a24c45ae2cfd03dcef169005ff7d459ab82b24719c3ca27c61e99b04d49"
      else
        url "https://github.com/waltarix/hexyl/releases/download/v#{v}-custom/hexyl-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "07fc2071f8ac1b4d824da49ebae884c6b152ded64581d6ab4da094a35493b3a4"
      end
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
