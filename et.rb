class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTCP/"
  url "https://github.com/MisterTea/EternalTCP/archive/et-v4.1.0.tar.gz"
  sha256 "a6a99e425da3354c1845c5b8eb1644ffc0ee96b8644f2b905191e7102703a18b"

  depends_on "cmake" => :build

  depends_on "protobuf"
  depends_on "libsodium"
  depends_on "glog"
  depends_on "gflags"

  patch :DATA if OS.linux?

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    etc.install "etc/et.cfg" => "et.cfg" unless File.exist? etc+"et.cfg"
  end

  if OS.mac?
    plist_options :startup => true

    def plist; <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/etserver</string>
          <string>--cfgfile</string>
          <string>#{etc}/et.cfg</string>
          <string>--daemon</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardErrorPath</key>
        <string>/tmp/et_err</string>
        <key>StandardOutPath</key>
        <string>/tmp/et_err</string>
        <key>HardResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>4096</integer>
        </dict>
        <key>SoftResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>4096</integer>
        </dict>
      </dict>
      </plist>
      EOS
    end
  end

  test do
    system "#{bin}/et", "--help"
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 99a53eb..0dc716a 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -28,7 +28,6 @@ find_package(Glog REQUIRED)
 find_package(GFlags REQUIRED)
 find_package(Protobuf REQUIRED)
 find_package(Sodium REQUIRED)
-find_package(SELinux)
 find_package(UTempter)
 
 IF(SELINUX_FOUND)
