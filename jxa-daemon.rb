class JxaDaemon < Formula
  desc "Daemon for JXA"
  homepage "https://github.com/waltarix/misc/tree/master/daemons"
  url "https://raw.githubusercontent.com/waltarix/misc/20210225/daemons/jxa_daemon.rb"
  version "20210225"
  sha256 "d5a88de6ddfd53a91ea541ab0c89beb87c087c11c11df6901ce5fc68fb9f79eb"

  depends_on "ruby"

  resource "fast_jsonparser" do
    url "https://rubygems.org/downloads/oj-3.13.23.gem"
    sha256 "206dfdc4020ad9974705037f269cfba211d61b7662a58c717cce771829ccef51"
  end

  def install
    ENV["GEM_HOME"] = libexec
    resources.each do |r|
      r.fetch
      system "gem", "install", r.cached_download, "--ignore-dependencies",
                    "--no-document", "--install-dir", libexec
    end

    libexec.install "jxa_daemon.rb" => "jxa-daemon"
    chmod 0555, libexec/"jxa-daemon"
    (bin/"jxa-daemon").write_env_script libexec/"jxa-daemon",
      PATH:     "#{Formula["ruby"].opt_bin}:$PATH",
      GEM_HOME: ENV["GEM_HOME"]
  end

  service do
    run [opt_bin/"jxa-daemon"]
    run_type :immediate
    keep_alive true
    require_root true
    working_dir HOMEBREW_PREFIX
    environment_variables LANG: "en_US.UTF-8"
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
