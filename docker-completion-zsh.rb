class DockerCompletionZsh < Formula
  desc "Zsh completion for Docker"
  homepage "https://www.docker.com/"
  url "https://raw.githubusercontent.com/docker/cli/v20.10.17/contrib/completion/zsh/_docker"
  sha256 "cd3d69fe80273dfc6f3336cbe8870272bc8b692200a8359ed846ccf3a68949df"
  license "Apache-2.0"

  livecheck do
    formula "docker"
  end

  conflicts_with "docker",
    because: "docker already includes this completion script"
  conflicts_with "docker-completion",
    because: "docker-completion already includes this completion script"

  patch :DATA

  def install
    zsh_completion.install "_docker"
  end
end

__END__
--- a/_docker
+++ b/_docker
@@ -181,7 +181,7 @@
     for m in $onlyrepos; do
         [[ ${PREFIX##${~~m}} != ${PREFIX} ]] && {
             # Yes, complete with tags
-            repos=(${${repos/:::/:}/:/\\:})
+            repos=(${${repos/:::/:}//:/\\:})
             _describe -t docker-repos-with-tags "repositories with tags" repos && ret=0
             return ret
         }
