class Erdtree < Formula
  desc "Multi-threaded file-tree visualizer and disk usage analyzer"
  homepage "https://github.com/solidiquis/erdtree"
  "3.0.2".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "d8e78e6cb33ea90d85bdaac6e2f0bd12e8eafcaf6a6d25bcbce470d83cf41710"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "60568dc34ca1009a2caef69a7e3ddb24611100f60df55ce762541dc53da90351"
      else
        url "https://github.com/waltarix/erdtree/releases/download/v#{v}-custom/erd-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "f46cc42e0f25389f7dc83787231ed30787f6e5cdefe78584602d7aa60e4c752f"
      end
    end
  end
  license "MIT"

  def install
    bin.install "erd"

    generate_completions_from_executable(bin/"erd", "--completions")
  end

  test do
    touch "test.txt"
    assert_match "test.txt", shell_output("#{bin}/erd")
  end
end
