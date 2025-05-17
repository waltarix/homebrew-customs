class Otree < Formula
  desc "Command-line tool to view objects (JSON/YAML/TOML) in TUI tree widget"
  homepage "https://github.com/fioncat/otree"
  "0.4.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "73234cfd2ce0ddf97862b56f44947960663e788bbaa3bd4a96c3f5f71cd1a560"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "9eb9fab7d07dc042e3446e5f5093a6d9c04922f30d83d2806d55151878746006"
      else
        url "https://github.com/waltarix/otree/releases/download/v#{v}-custom/otree-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "1853aedf7fe5b829edddf5f4bf32031c43619eb977c919c2eae58c174392a76e"
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
