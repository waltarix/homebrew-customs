class DockerCompletionZsh < Formula
  desc "Zsh completion for Docker"
  homepage "https://www.docker.com/"
  url "https://raw.githubusercontent.com/docker/docker-ce/v19.03.12/components/cli/contrib/completion/zsh/_docker"
  sha256 "cdecf8b89d8fc5e796266782a59fd21adb69340a47513746f15b1ba0cc196725"
  license "Apache-2.0"

  bottle :unneeded

  conflicts_with "docker",
    because: "docker already includes this completion script"
  conflicts_with "docker-completion",
    because: "docker-completion already includes this completion script"

  patch :DATA

  def install
    zsh_completion.install "_docker"
  end

  test do
    assert_match "-F _docker",
      shell_output("bash -c 'source #{bash_completion}/docker && complete -p docker'")
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
