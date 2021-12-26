class TmuxpCompletionZsh < Formula
  desc "Zsh completion for Tmuxp"
  homepage "https://github.com/zsh-users/zsh-completions"
  url "https://raw.githubusercontent.com/zsh-users/zsh-completions/0fd25cda7a31205bbee090d58752c323541c19b8/src/_tmuxp"
  sha256 "6bb542b0709c5168af622d0711776f8ea493c2808f6e4442afa589e1c76e1abf"
  version "20211113"
  license "MIT-Modern-Variant"

  patch :DATA

  def install
    zsh_completion.install "_tmuxp"
  end

  test do
    assert_match "_tmuxp is an autoload shell function",
      shell_output("zsh -c 'autoload -Uz compinit; compinit; whence -v _tmuxp'")
  end
end

__END__
--- a/_tmuxp
+++ b/_tmuxp
@@ -96,13 +96,15 @@
   # Can't get the options to be recognized when there are sessions that has
   # a dash.
 
+  local configdir=$XDG_CONFIG_HOME/tmuxp
+  local configdir_hostbased=$configdir/${HOST:r}
   case $state in
     (sessions)
       local s
       _alternative \
-        'sessions-user:user session:compadd -F line - ~/.tmuxp/*.(json|yml|yaml)(:r:t)' \
-        'sessions-other:session in current directory:_path_files -/ -g "**/.tmuxp.(yml|yaml|json)"' \
-        'sessions-other:session in current directory:_path_files -g "*.(yml|yaml|json)"'
+        'sessions-user:user session:compadd -F line - ${configdir}/*.(json|yml|yaml)(:r:t)' \
+        'sessions-user-hostbased:host based user session ('${HOST:r}'):compadd -P ${configdir_hostbased/#$HOME/\~}/ ${configdir_hostbased}/**/*.(yml|yaml|json)(:gs@$configdir_hostbased/@@)' \
+        'sessions-other:session in current directory:_path_files -g ".tmuxp.(yml|yaml|json)"'
       ;;
   esac
 }
@@ -131,4 +133,3 @@
 }
 
 _tmuxp "$@"
-
