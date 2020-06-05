class JxaDaemon < Formula
  desc "Daemon for JXA"
  homepage "https://github.com/waltarix/misc/tree/master/daemons"
  url "https://raw.githubusercontent.com/waltarix/misc/20200605/daemons/jxa_daemon.rb"
  version "20200605"
  sha256 "8c2264717b5a19b7909e140f975f864aeed27db9d910b79fd81f3d78aec1384d"

  bottle :unneeded

  def install
    libexec.install "jxa_daemon.rb" => "jxa-daemon"

    ENV["GEM_HOME"] = libexec
    system "gem", "install", "oj"

    chmod 0555, libexec/"jxa-daemon"
    (bin/"jxa-daemon").write_env_script(libexec/"jxa-daemon", :GEM_HOME => libexec)
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/jxa_daemon/bin/jxa-daemon"

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
          <string>/usr/bin/ruby</string>
          <string>#{libexec}/jxa-daemon</string>
        </array>
        <key>EnvironmentVariables</key>
        <dict>
          <key>GEM_HOME</key>
          <string>#{libexec}</string>
        </dict>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
      </plist>
    EOS
  end

  test do
    pid = Process.spawn({ "PATH" => "/usr/bin:/bin:/usr/sbin:/sbin" }, bin/"jxa-daemon")
    sleep 1

    require "socket"
    UNIXSocket.open("/tmp/jxa-daemon.sock") do |sock|
      sock.puts("return 1 + 2 + 3")
      assert_match(/^6$/, sock.read)
    end
    Process.kill :TERM, pid
  end
end
