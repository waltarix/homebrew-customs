class Otree < Formula
  desc "Command-line tool to view objects (JSON/YAML/TOML) in TUI tree widget"
  homepage "https://github.com/fioncat/otree"
  "0.2.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "966ed2ef854c4bdd57c8d53cfeb015f6932dc1f8838514fe3506660ed22e87a6"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "2e25fc7162d2c2d1cd986d249e75b12b8b9048eb76c07ed9ba39e88cdf48ad30"
      else
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "c87bf8fe2b2085fa1c9876acfd5724f38b60ff126a1004544848509ae4a90415"
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
