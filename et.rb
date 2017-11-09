class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTCP/"
  url "https://github.com/MisterTea/EternalTCP/archive/et-v4.1.0.tar.gz"
  sha256 "a6a99e425da3354c1845c5b8eb1644ffc0ee96b8644f2b905191e7102703a18b"
  revision 3

  depends_on "cmake" => :build

  depends_on "protobuf"
  depends_on "libsodium"
  depends_on "glog"
  depends_on "gflags"

  patch :DATA

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
diff --git a/README.md b/README.md
index 0f7e47a..1b97298 100644
--- a/README.md
+++ b/README.md
@@ -68,14 +68,14 @@ You are ready to start using ET!
 
 ET uses ssh for handshaking and encryption, so you must be able to ssh into the machine from the client. Make sure that you can `ssh user@hostname`.
 
-ET uses TCP, so you need an open port on your server. By default, it uses 2022.
+ET uses TCP, so you need an open port on your server. By default, it uses 25253.
 
 
-Once you have an open port, the syntax is shown below. You can specify a jumphost and the port et is running on jumphost using `--jumphost` and `--jport`. If no `--port/--jport` is given, et will try to connect to default port 2022.
+Once you have an open port, the syntax is shown below. You can specify a jumphost and the port et is running on jumphost using `--jumphost` and `--jport`. If no `--port/--jport` is given, et will try to connect to default port 25253.
 ```
-et --host hostname (etserver running on port 2022)
+et --host hostname (etserver running on port 25253)
 et --host hostname --port 8000
-et --host hostname --jumphost (etserver running on port 2022 on both hostname and jumphost)
+et --host hostname --jumphost (etserver running on port 25253 on both hostname and jumphost)
 et --host hostname --port 8888 --jumphost jump_hostname --jport 9999
 ```
 Additional arguments that et accept are port forwarding pairs with option `--portforward="18000:8000, 18001-18003:8001-8003"`, a command to run immediately after the connection is setup through `--command`. Username is default to the current username starting the et process, use `--user` to specify a different if necessary.
@@ -98,7 +98,7 @@ Host dev
 With the ssh config file set as above, you can simply call et with
 
 ```
-et --host dev (etserver running on port 2022 on both hostname and jumphost)
+et --host dev (etserver running on port 25253 on both hostname and jumphost)
 et --host dev --port 8000 --jport 9000 (etserver not running on default port)
 ```
 
diff --git a/etc/et.cfg b/etc/et.cfg
index 403ab02..cc4b8c4 100644
--- a/etc/et.cfg
+++ b/etc/et.cfg
@@ -2,4 +2,4 @@
 ;
 
 [Networking]
-port = 2022
+port = 25253
diff --git a/src/UnixSocketHandler.cpp b/src/UnixSocketHandler.cpp
index b9acde0..17bfd2e 100644
--- a/src/UnixSocketHandler.cpp
+++ b/src/UnixSocketHandler.cpp
@@ -98,6 +98,9 @@ int UnixSocketHandler::connect(const std::string &hostname, int port) {
 
   // loop through all the results and connect to the first we can
   for (p = results; p != NULL; p = p->ai_next) {
+    if (p->ai_family == AF_INET6) {
+      continue;
+    }
     if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
       LOG(INFO) << "Error creating socket: " << errno << " " << strerror(errno);
       continue;
@@ -219,6 +222,9 @@ void UnixSocketHandler::createServerSockets(int port) {
   set<int> serverSockets;
   // loop through all the results and bind to the first we can
   for (p = servinfo; p != NULL; p = p->ai_next) {
+    if (p->ai_family == AF_INET6) {
+      continue;
+    }
     int sockfd;
     if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
       LOG(INFO) << "Error creating socket " << p->ai_family << "/"
diff --git a/terminal/SshSetupHandler.cpp b/terminal/SshSetupHandler.cpp
index 3a482dd..f61c5c5 100644
--- a/terminal/SshSetupHandler.cpp
+++ b/terminal/SshSetupHandler.cpp
@@ -61,11 +61,11 @@ string SshSetupHandler::SetupSsh(string user, string host, int port,
     close(link_client[0]);
     close(link_client[1]);
     if (!jumphost.empty()) {
-      execl("/usr/bin/ssh", "/usr/bin/ssh", "-J",
+      execl("/usr/bin/env", "/usr/bin/env", "ssh", "-J",
             (SSH_USER_PREFIX + jumphost).c_str(),
             (SSH_USER_PREFIX + host).c_str(), (SSH_SCRIPT_DST).c_str(), NULL);
     } else {
-      execl("/usr/bin/ssh", "/usr/bin/ssh", (SSH_USER_PREFIX + host).c_str(),
+      execl("/usr/bin/env", "/usr/bin/env", "ssh", (SSH_USER_PREFIX + host).c_str(),
             (SSH_SCRIPT_DST).c_str(), NULL);
     }
 
@@ -124,7 +124,7 @@ string SshSetupHandler::SetupSsh(string user, string host, int port,
         cmdoptions +=
             " --jump --dsthost=" + host + " --dstport=" + to_string(port);
         string SSH_SCRIPT_JUMP = SSH_SCRIPT_PREFIX + cmdoptions + ";true";
-        execl("/usr/bin/ssh", "/usr/bin/ssh", jumphost.c_str(),
+        execl("/usr/bin/env", "/usr/bin/env", "ssh", jumphost.c_str(),
               (SSH_SCRIPT_JUMP).c_str(), NULL);
       } else {
         close(link_jump[1]);
diff --git a/terminal/TerminalClient.cpp b/terminal/TerminalClient.cpp
index 22c1e00..63cddb1 100644
--- a/terminal/TerminalClient.cpp
+++ b/terminal/TerminalClient.cpp
@@ -33,14 +33,14 @@ termios terminal_backup;
 
 DEFINE_string(user, "", "username to login");
 DEFINE_string(host, "localhost", "host to join");
-DEFINE_int32(port, 2022, "port to connect on");
+DEFINE_int32(port, 25253, "port to connect on");
 DEFINE_string(c, "", "Command to run immediately after connecting");
 DEFINE_string(t, "",
               "Array of source:destination ports or "
               "srcStart-srcEnd:dstStart-dstEnd (inclusive) port ranges (e.g. "
               "10080:80,10443:443, 10090-10092:8000-8002)");
 DEFINE_string(jumphost, "", "jumphost between localhost and destination");
-DEFINE_int32(jport, 2022, "port to connect on jumphost");
+DEFINE_int32(jport, 25253, "port to connect on jumphost");
 
 shared_ptr<ClientConnection> createClient(string idpasskeypair) {
   string id = "", passkey = "";
@@ -121,7 +121,7 @@ int main(int argc, char** argv) {
       cout << "et (options) [user@]hostname[:port]\n"
 "Options:\n"
 "-h Basic usage\n"
-"-p Port for etserver to run on.  Default: 2022\n"
+"-p Port for etserver to run on.  Default: 25253\n"
 "-u Username to connect to ssh & ET\n"
 "-v=9 verbose log files\n"
 "-c Initial command to execute upon connecting\n"
diff --git a/terminal/TerminalServer.cpp b/terminal/TerminalServer.cpp
index 25dec94..154edd6 100644
--- a/terminal/TerminalServer.cpp
+++ b/terminal/TerminalServer.cpp
@@ -59,7 +59,7 @@ DEFINE_string(cfgfile, "", "Location of the config file");
 DEFINE_bool(jump, false,
             "If set, forward all packets between client and dst terminal");
 DEFINE_string(dsthost, "", "Must be set if jump is set to true");
-DEFINE_int32(dstport, 2022, "Must be set if jump is set to true");
+DEFINE_int32(dstport, 25253, "Must be set if jump is set to true");
 
 shared_ptr<ServerConnection> globalServer;
 shared_ptr<UserTerminalRouter> terminalRouter;
@@ -235,12 +235,7 @@ void runTerminal(shared_ptr<ServerClientConnection> serverClientState) {
               LOG(INFO) << "Got new port forward";
               PortForwardRequest pfr =
                   serverClientState->readProto<PortForwardRequest>();
-              // Try ipv6 first
-              int fd = socketHandler->connect("::1", pfr.port());
-              if (fd == -1) {
-                // Try ipv4 next
-                fd = socketHandler->connect("127.0.0.1", pfr.port());
-              }
+              int fd = socketHandler->connect("127.0.0.1", pfr.port());
               PortForwardResponse pfresponse;
               pfresponse.set_clientfd(pfr.fd());
               if (fd == -1) {
@@ -576,7 +571,7 @@ int main(int argc, char **argv) {
   }
 
   if (FLAGS_port == 0) {
-    FLAGS_port = 2022;
+    FLAGS_port = 25253;
   }
 
   if (FLAGS_jump) {
