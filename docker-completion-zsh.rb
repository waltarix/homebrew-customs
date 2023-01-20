class DockerCompletionZsh < Formula
  desc "Zsh completion for Docker"
  homepage "https://www.docker.com/"
  url "https://raw.githubusercontent.com/docker/cli/1af9f22c7e070d481c4916a673ee625eeafd755e/contrib/completion/zsh/_docker"
  version "23.0.0-rc"
  sha256 "ad147f0b6bfff59c10fb5d6f0132670c2eec02cdd829efbf1aac36b69eb009a9"
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
