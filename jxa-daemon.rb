class JxaDaemon < Formula
  desc "Daemon for JXA"
  homepage "https://github.com/waltarix/misc/tree/master/daemons"
  url "https://raw.githubusercontent.com/waltarix/misc/20210225/daemons/jxa_daemon.rb"
  version "20210225"
  sha256 "d5a88de6ddfd53a91ea541ab0c89beb87c087c11c11df6901ce5fc68fb9f79eb"

  bottle :unneeded

  depends_on "ruby"

  resource "fast_jsonparser" do
    url "https://rubygems.org/downloads/oj-3.11.0.gem"
    sha256 "470d6ac425efd19c526ecea1cabb0219dd8bbcbdeeec57bd45a803b5e082ab5b"
  end

  def install
    ENV["GEM_HOME"] = libexec
    resources.each do |r|
      r.fetch
      system "gem", "install", r.cached_download, "--no-document",
                    "--install-dir", libexec
    end

    libexec.install "jxa_daemon.rb" => "jxa-daemon"
    jxa_daemon = libexec/"jxa-daemon"
    chmod 0555, jxa_daemon
    ruby = Formula["ruby"].opt_bin/"ruby"
    (bin/"jxa-daemon").write_env_script(ruby, jxa_daemon, GEM_HOME: ENV["GEM_HOME"])
  end

  plist_options manual: "#{HOMEBREW_PREFIX}/opt/jxa_daemon/bin/jxa-daemon"

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
          <string>#{opt_bin}/jxa-daemon</string>
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
