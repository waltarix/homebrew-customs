class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  ["0.25.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "f36238eb2578de908ba65cd851b1381158e3b7e70587e55f39a6c9aa489f6f48"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "a649b50fe25948af98aca249ca34e9acf31d62d95ab46f13ce5a11ffb81f68d7"
      else
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "8ef106274125ebbd37eba55306cfbdde428c031268f3b21901784d45346e96e0"
      end
    end
    revision r if r
  end
  license any_of: ["Apache-2.0", "MIT"]

  def install
    bin.install "bat"
    man1.install "manual/bat.1"
    generate_completions_from_executable(bin/"bat", "--completion")
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/bat #{pdf} --color=never")
    assert_match "Homebrew test", output
  end
end
