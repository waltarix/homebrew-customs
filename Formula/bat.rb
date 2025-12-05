class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  ["0.26.1", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "50c2728cab1f1f25320a9344f315909a59110074177bd8717c5661b93bb5000e"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "3dfd07000b54babd175a578bce95343d8abc9b86cf95a4164429db2f966eeb35"
      else
        url "https://github.com/waltarix/bat/releases/download/v#{v}-custom#{rev}/bat-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "95f5add32cbfbfddd6031787f7f96a9c83aa66662e568ed80044ee934db762dd"
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
