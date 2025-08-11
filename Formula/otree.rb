class Otree < Formula
  desc "Command-line tool to view objects (JSON/YAML/TOML) in TUI tree widget"
  homepage "https://github.com/fioncat/otree"
  "0.5.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "5969dea27bf99f49bbd4d9c02d7acfa4665eace42ed6b89e144114f28aa5d29e"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "9f716cc0236d76f62c05edb3b13b558a1408e55715386656e63a6451e8bd0569"
      else
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "12e1af93b5bf331b5550a225e1836beec9f3a01e97c9365ab6b183ac73abda99"
      end
    end
  end
  license "MIT"
  head "https://github.com/fioncat/otree.git", branch: "main"

  def install
    bin.install "otree"
  end

  test do
    (testpath/"example.json").write <<~JSON
      {
        "string": "Hello, World!",
        "number": 12345,
        "float": 123.45
      }
    JSON
    require "pty"
    r, w, pid = PTY.spawn("#{bin}/otree example.json")
    r.winsize = [36, 120]
    sleep 1
    w.write "q"
    begin
      output = r.read
      assert_match "Hello, World!", output
      assert_match "12345", output
      assert_match "123.45", output
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    end
  ensure
    Process.kill("TERM", pid)
  end
end
