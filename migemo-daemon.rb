class MigemoDaemon < Formula
  desc "Daemon for cmigemo"
  homepage "https://github.com/waltarix/misc/tree/master/daemons"
  url "https://raw.githubusercontent.com/waltarix/misc/20200605/daemons/migemo_daemon.rb"
  version "20200605"
  sha256 "0e15bbd80877ae7485e1eedd225badc02b86804367866a05fd167dc7d76acc9f"

  depends_on "ruby"
  depends_on "waltarix/customs/cmigemo"

  def install
    libexec.install "migemo_daemon.rb" => "migemo-daemon"
    chmod 0555, libexec/"migemo-daemon"
    (bin/"migemo-daemon").write_env_script libexec/"migemo-daemon",
      PATH: "#{Formula["cmigemo"].opt_bin}:#{Formula["ruby"].opt_bin}:$PATH"
  end

  service do
    run [opt_bin/"migemo-daemon"]
    run_type :immediate
    keep_alive true
    require_root true
    working_dir HOMEBREW_PREFIX
    environment_variables LANG: "en_US.UTF-8"
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
