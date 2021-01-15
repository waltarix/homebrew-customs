class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  url "https://github.com/sharkdp/bat/archive/v0.17.1.tar.gz"
  sha256 "16d39414e8a3b80d890cfdbca6c0e6ff280058397f4a3066c37e0998985d87c4"
  license "Apache-2.0"

  bottle :unneeded

  resource "assets" do
    if OS.linux?
      url "https://github.com/sharkdp/bat/releases/download/v0.17.1/bat-v0.17.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "99fc9f0ad6115e54424dcf709ee5cffc4083d6a8c8a1b527625cd22ec37cb4c7"
    else
      url "https://github.com/sharkdp/bat/releases/download/v0.17.1/bat-v0.17.1-x86_64-apple-darwin.tar.gz"
      sha256 "904d39e0d8b7d3edefe19115f34d4da0456c89b646e8d5ad5a462670f385fbcb"
    end

    patch :DATA
  end

  def install
    resource("assets").stage do
      bin.install "bat"
      man1.install "bat.1"
      fish_completion.install "autocomplete/bat.fish"
      zsh_completion.install "autocomplete/bat.zsh" => "_bat"
    end
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/bat #{pdf} --color=never")
    assert_match "Homebrew test", output
  end
end

__END__
--- a/autocomplete/bat.zsh
+++ b/autocomplete/bat.zsh
@@ -1,6 +1,6 @@
 #compdef bat
 
-local context state state_descr line
+local context state state_descr line ret=1
 typeset -A opt_args
 
 (( $+functions[_bat_cache_subcommand] )) ||
@@ -49,7 +49,7 @@
         '*: :_files'
     )
 
-    _arguments -S -s $args
+    _arguments -S -s $args && ret=0
 
     case "$state" in
         language)
@@ -57,7 +57,7 @@
             local -a languages
             languages=( $(bat --list-languages | awk -F':|,' '{ for (i = 1; i <= NF; ++i) printf("%s:%s\n", $i, $1) }') )
 
-            _describe 'language' languages
+            _describe 'language' languages && ret=0
         ;;
 
         theme)
@@ -72,6 +72,8 @@
             _values -s , 'style' auto full plain changes header grid numbers snip
         ;;
     esac
+
+    return ret
 }
 
 # first positional argument
