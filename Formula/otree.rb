class Otree < Formula
  desc "Command-line tool to view objects (JSON/YAML/TOML) in TUI tree widget"
  homepage "https://github.com/fioncat/otree"
  "0.6.1".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "dfdbd38a78976e066e438293bed32104b4511b60fd103f124b3bde9143ebf133"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "bf45565a9d1d55d78e805dbdc6bdf1b450bbc0f0b184b485d87bf3eb212ad22c"
      else
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "319445f0b77bd002001cde800eb84963e42b27132962d8186e8d9cec8f920a23"
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
