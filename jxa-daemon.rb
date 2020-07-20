class JxaDaemon < Formula
  desc "Daemon for JXA"
  homepage "https://github.com/waltarix/misc/tree/master/daemons"
  url "https://raw.githubusercontent.com/waltarix/misc/20200720/daemons/jxa_daemon.rb"
  version "20200720"
  sha256 "2a10483b59bcbaa84d0e1aea81ee8523c68b499de862c9c5d5195a4c9aeeb537"

  bottle :unneeded

  def install
    libexec.install "jxa_daemon.rb" => "jxa-daemon"

    ENV["GEM_HOME"] = libexec
    system "gem", "install", "fast_jsonparser", "-v", "0.3.0", "--",
                  "--with-cxxflags=-Wno-reserved-user-defined-literal"

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
