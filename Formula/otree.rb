class Otree < Formula
  desc "Command-line tool to view objects (JSON/YAML/TOML) in TUI tree widget"
  homepage "https://github.com/fioncat/otree"
  "0.6.2".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "7c9d4712b467c235eb0cdb647f1d1828561834a215b8beab6aaccad124ab66d0"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "4410219d8b01db145bc253896725fa50c770a8c593457ed4377c3df986c1b5d6"
      else
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "051cc73328e9c9e0789b91815baecd43938771083f993ecaca8ac5bbef975c6c"
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
