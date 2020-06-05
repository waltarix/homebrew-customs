class MigemoDaemon < Formula
  desc "Daemon for cmigemo"
  homepage "https://github.com/waltarix/misc/tree/master/daemons"
  url "https://raw.githubusercontent.com/waltarix/misc/20200605/daemons/migemo_daemon.rb"
  version "20200605"
  sha256 "0e15bbd80877ae7485e1eedd225badc02b86804367866a05fd167dc7d76acc9f"

  bottle :unneeded

  depends_on "waltarix/customs/cmigemo"

  def install
    libexec.install "migemo_daemon.rb" => "migemo-daemon"

    chmod 0555, libexec/"migemo-daemon"
    env = {
      :PATH => "#{Formula["cmigemo"].opt_bin}:$PATH",
    }
    (bin/"migemo-daemon").write_env_script(libexec/"migemo-daemon", env)
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/migemo_daemon/bin/migemo-daemon"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{bin}/migemo-daemon</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
      </plist>
    EOS
  end

  test do
    pid = Process.spawn(bin/"migemo-daemon")
    sleep 1

    require "socket"
    UNIXSocket.open("/tmp/migemo-daemon.sock") do |sock|
      sock.puts("hoge")
      assert_match "ほげ", sock.read.force_encoding(Encoding::UTF_8)
    end
    Process.kill :TERM, pid
  end
end
