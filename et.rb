class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTCP/"
  url "https://github.com/MisterTea/EternalTCP/archive/et-v4.1.1.tar.gz"
  version "4.1.1"
  sha256 "db62c323d978509eae0e5c3427299f7e38287b2595a52f34db9d45a375493c67"

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
index b03aab6..1a6b552 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -33,9 +33,6 @@ find_package(Glog REQUIRED)
 find_package(GFlags REQUIRED)
 find_package(Protobuf REQUIRED)
 find_package(Sodium REQUIRED)
-IF(LINUX)
-find_package(SELinux)
-ENDIF()
 find_package(UTempter)
 
 IF(SELINUX_FOUND)
diff --git a/README.md b/README.md
index 8ecb958..3ec5fcf 100644
--- a/README.md
+++ b/README.md
@@ -68,17 +68,17 @@ You are ready to start using ET!
 
 ET uses ssh for handshaking and encryption, so you must be able to ssh into the machine from the client. Make sure that you can `ssh user@hostname`.
 
-ET uses TCP, so you need an open port on your server. By default, it uses 2022.
+ET uses TCP, so you need an open port on your server. By default, it uses 25253.
 
 
 Once you have an open port, the syntax is similar to ssh. Username is default to the current username starting the et process, use `-u` or `user@` to specify a different if necessary.
 ```
-et hostname (etserver running on default port 2022, username is the same as current)
+et hostname (etserver running on default port 25253, username is the same as current)
 et user@hostname:8000 (etserver running on port 8000, different user)
 ```
-You can specify a jumphost and the port et is running on jumphost using `-jumphost` and `-jport`. If no `-jport` is given, et will try to connect to default port 2022.
+You can specify a jumphost and the port et is running on jumphost using `-jumphost` and `-jport`. If no `-jport` is given, et will try to connect to default port 25253.
 ```
-et hostname -jumphost jump_hostname (etserver running on port 2022 on both hostname and jumphost)
+et hostname -jumphost jump_hostname (etserver running on port 25253 on both hostname and jumphost)
 et hostname:8888 -jumphost jump_hostname -jport 9999
 ```
 Additional arguments that et accept are port forwarding pairs with option `-t="18000:8000, 18001-18003:8001-8003"`, a command to run immediately after the connection is setup through `-c`.
@@ -101,7 +101,7 @@ Host dev
 With the ssh config file set as above, you can simply call et with
 
 ```
-et dev (etserver running on port 2022 on both hostname and jumphost)
+et dev (etserver running on port 25253 on both hostname and jumphost)
 et dev:8000 -jport 9000 (etserver running on port 9000 on jumphost)
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
diff --git a/replace_default_port.zsh b/replace_default_port.zsh
new file mode 100755
index 0000000..ef3e7f4
--- /dev/null
+++ b/replace_default_port.zsh
@@ -0,0 +1,17 @@
+#!/usr/bin/env zsh
+
+local default_port=25253
+local new_port=$1
+
+[[ -z $new_port ]] && { echo 'invalid arguments.'; return 1 }
+
+function replace_port {
+	perl -i -pe "s/\b${default_port}\b/${new_port}/g" $1
+}
+
+local -a target_files
+target_files=($(git grep --name-only -w 25253))
+
+for target_file ($target_files); do
+	replace_port $target_file
+done
diff --git a/src/UnixSocketHandler.cpp b/src/UnixSocketHandler.cpp
index b9acde0..e9b8f37 100644
--- a/src/UnixSocketHandler.cpp
+++ b/src/UnixSocketHandler.cpp
@@ -70,7 +70,7 @@ int UnixSocketHandler::connect(const std::string &hostname, int port) {
   addrinfo *p = NULL;
   addrinfo hints;
   memset(&hints, 0, sizeof(addrinfo));
-  hints.ai_family = AF_UNSPEC;
+  hints.ai_family = AF_INET;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_flags = (AI_CANONNAME | AI_V4MAPPED | AI_ADDRCONFIG | AI_ALL);
   std::string portname = std::to_string(port);
@@ -204,7 +204,7 @@ void UnixSocketHandler::createServerSockets(int port) {
   int rc;
 
   memset(&hints, 0, sizeof hints);
-  hints.ai_family = AF_UNSPEC;
+  hints.ai_family = AF_INET;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_flags = AI_PASSIVE;  // use my IP address
 
diff --git a/terminal/SshSetupHandler.cpp b/terminal/SshSetupHandler.cpp
index 5056e63..1a73547 100644
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
 
@@ -123,7 +123,7 @@ string SshSetupHandler::SetupSsh(string user, string host, int port,
         cmdoptions +=
             " --jump --dsthost=" + host + " --dstport=" + to_string(port);
         string SSH_SCRIPT_JUMP = SSH_SCRIPT_PREFIX + cmdoptions + ";true";
-        execl("/usr/bin/ssh", "/usr/bin/ssh", jumphost.c_str(),
+        execl("/usr/bin/env", "/usr/bin/env", "ssh", jumphost.c_str(),
               (SSH_SCRIPT_JUMP).c_str(), NULL);
       } else {
         close(link_jump[1]);
diff --git a/terminal/TerminalClient.cpp b/terminal/TerminalClient.cpp
index e71dfe7..1f6471b 100644
--- a/terminal/TerminalClient.cpp
+++ b/terminal/TerminalClient.cpp
@@ -33,14 +33,14 @@ termios terminal_backup;
 
 DEFINE_string(u, "", "username to login");
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
-              "-p Port for etserver to run on.  Default: 2022\n"
+              "-p Port for etserver to run on.  Default: 25253\n"
               "-u Username to connect to ssh & ET\n"
               "-v=9 verbose log files\n"
               "-c Initial command to execute upon connecting\n"
diff --git a/terminal/TerminalServer.cpp b/terminal/TerminalServer.cpp
index f016dd4..0f2cd32 100644
--- a/terminal/TerminalServer.cpp
+++ b/terminal/TerminalServer.cpp
@@ -60,7 +60,7 @@ DEFINE_string(cfgfile, "", "Location of the config file");
 DEFINE_bool(jump, false,
             "If set, forward all packets between client and dst terminal");
 DEFINE_string(dsthost, "", "Must be set if jump is set to true");
-DEFINE_int32(dstport, 2022, "Must be set if jump is set to true");
+DEFINE_int32(dstport, 25253, "Must be set if jump is set to true");
 
 shared_ptr<ServerConnection> globalServer;
 shared_ptr<UserTerminalRouter> terminalRouter;
@@ -236,12 +236,7 @@ void runTerminal(shared_ptr<ServerClientConnection> serverClientState) {
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
@@ -577,7 +572,7 @@ int main(int argc, char **argv) {
   }
 
   if (FLAGS_port == 0) {
-    FLAGS_port = 2022;
+    FLAGS_port = 25253;
   }
 
   if (FLAGS_jump) {
