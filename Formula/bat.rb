class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  ["0.26.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "dc105a90885804d4329d2dbc246ee2805483905987451b000421db6018c4b341"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "77fe8b9fef6fb970dbd2442dabf3b162c3b85a4cc854f1041bd956e63f79c95c"
      else
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "c2bdadd3871e1802e3814440b65447cef8feea40b8c612a3c6066d676680a918"
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
