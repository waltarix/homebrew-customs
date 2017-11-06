class Sshrc < Formula
  desc "Bring your .bashrc, .vimrc, etc. with you when you SSH"
  homepage "https://github.com/Russell91/sshrc"
  url "https://github.com/Russell91/sshrc/archive/0.6.1.tar.gz"
  sha256 "e849ff19319381548011a9bdf1e33abc6eba3dc6a910c4226e6981d75d5564dd"

  head "https://github.com/Russell91/sshrc.git"

  bottle :unneeded

  patch :DATA

  def install
    bin.install %w[sshrc moshrc]
  end

  test do
    touch testpath/".sshrc"
    (testpath/"ssh").write <<~EOS
      #!/bin/sh
      true
    EOS
    chmod 0755, testpath/"ssh"
    ENV.prepend_path "PATH", testpath
    system "#{bin}/sshrc"
  end
end

__END__
diff --git a/moshrc b/moshrc
index 5f34a78..37f0ce9 100755
--- a/moshrc
+++ b/moshrc
@@ -21,18 +21,18 @@ function moshrc() {
             export SSHHOME=\$(mktemp -d -t .$(whoami).sshrc.XXXX)
             export SSHRCCLEANUP=\$SSHHOME
             trap \"rm -rf \$SSHRCCLEANUP; exit\" 0
-            echo $'$(cat $0 | xxd -p)' | xxd -p -r > \$SSHHOME/moshrc
+            echo $'$(cat $0 | gzip -9c | xxd -p)' | xxd -p -r | gzip -dc > \$SSHHOME/moshrc
             chmod +x \$SSHHOME/moshrc
 
-            echo $'$( cat << 'EOF' | xxd -p
+            echo $'$( cat << 'EOF' | gzip -9c | xxd -p
 if [ -e /etc/bash.bashrc ]; then source /etc/bash.bashrc; fi
 if [ -e ~/.bashrc ]; then source ~/.bashrc; fi
 source $SSHHOME/.sshrc;
 export PATH=$PATH:$SSHHOME
 EOF
-)' | xxd -p -r > \$SSHHOME/sshrc.bashrc
+)' | xxd -p -r | gzip -dc > \$SSHHOME/sshrc.bashrc
 
-            echo $'$( cat << 'EOF' | xxd -p
+            echo $'$( cat << 'EOF' | gzip -9c | xxd -p
 #!/usr/bin/env bash
 exec bash --rcfile <(echo '
 if [ -e /etc/bash.bashrc ]; then source /etc/bash.bashrc; fi
@@ -41,10 +41,10 @@ source '$SSHHOME'/.sshrc;
 export PATH=$PATH:'$SSHHOME'
 ') "$@"
 EOF
-)' | xxd -p -r > \$SSHHOME/bashsshrc
+)' | xxd -p -r | gzip -dc > \$SSHHOME/bashsshrc
             chmod +x \$SSHHOME/bashsshrc
 
-            echo $'$(tar cz -h -C $SSHHOME $files | xxd -p)' | xxd -p -r | tar mxz -C \$SSHHOME
+            echo $'$(tar c -h -C $SSHHOME $files | gzip -9c | xxd -p)' | xxd -p -r | gzip -dc | tar mx -C \$SSHHOME
             export SSHHOME=\$SSHHOME
             bash --rcfile \$SSHHOME/sshrc.bashrc
             "
diff --git a/sshrc b/sshrc
index 5e487a5..9dc6c53 100755
--- a/sshrc
+++ b/sshrc
@@ -18,10 +18,10 @@ function sshrc() {
             export SSHHOME=\$(mktemp -d -t .$(whoami).sshrc.XXXX)
             export SSHRCCLEANUP=\$SSHHOME
             trap \"rm -rf \$SSHRCCLEANUP; exit\" 0
-            echo $'"$(cat "$0" | openssl enc -base64)"' | tr -s ' ' $'\n' | openssl enc -base64 -d > \$SSHHOME/sshrc
+            echo $'"$(cat "$0" | gzip -9c | openssl enc -base64)"' | tr -s ' ' $'\n' | openssl enc -base64 -d | gzip -dc > \$SSHHOME/sshrc
             chmod +x \$SSHHOME/sshrc
 
-            echo $'"$( cat << 'EOF' | openssl enc -base64
+            echo $'"$( cat << 'EOF' | gzip -9c | openssl enc -base64
 if [ -r /etc/profile ]; then source /etc/profile; fi
 if [ -r ~/.bash_profile ]; then source ~/.bash_profile
 elif [ -r ~/.bash_login ]; then source ~/.bash_login
@@ -30,9 +30,9 @@ fi
 export PATH=$PATH:$SSHHOME
 source $SSHHOME/.sshrc;
 EOF
-)"' | tr -s ' ' $'\n' | openssl enc -base64 -d > \$SSHHOME/sshrc.bashrc
+)"' | tr -s ' ' $'\n' | openssl enc -base64 -d | gzip -dc > \$SSHHOME/sshrc.bashrc
 
-            echo $'"$( cat << 'EOF' | openssl enc -base64
+            echo $'"$( cat << 'EOF' | gzip -9c | openssl enc -base64
 #!/usr/bin/env bash
 exec bash --rcfile <(echo '
 [ -r /etc/profile ] && source /etc/profile
@@ -44,10 +44,10 @@ source '$SSHHOME'/.sshrc;
 export PATH=$PATH:'$SSHHOME'
 ') "$@"
 EOF
-)"' | tr -s ' ' $'\n' | openssl enc -base64 -d > \$SSHHOME/bashsshrc
+)"' | tr -s ' ' $'\n' | openssl enc -base64 -d | gzip -dc > \$SSHHOME/bashsshrc
             chmod +x \$SSHHOME/bashsshrc
 
-            echo $'"$(tar cz -h -C $SSHHOME $files | openssl enc -base64)"' | tr -s ' ' $'\n' | openssl enc -base64 -d | tar mxz -C \$SSHHOME
+            echo $'"$(tar c -h -C $SSHHOME $files | gzip -9c | openssl enc -base64)"' | tr -s ' ' $'\n' | openssl enc -base64 -d | gzip -dc | tar mx -C \$SSHHOME
             export SSHHOME=\$SSHHOME
             bash --rcfile \$SSHHOME/sshrc.bashrc
             "
