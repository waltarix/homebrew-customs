class DockerCompletionZsh < Formula
  desc "Zsh completion for Docker"
  homepage "https://www.docker.com/"
  url "https://raw.githubusercontent.com/docker/docker-ce/v19.03.0-rc3/components/cli/contrib/completion/zsh/_docker"
  version "19.03.0-rc3"
  sha256 "54fbd8f1d1acaaf36f4d8784f86d8108f38adf4b95632f811ff772806c7a2608"

  bottle :unneeded

  conflicts_with "docker",
    :because => "docker already includes this completion script"
  conflicts_with "docker-completion",
    :because => "docker-completion already includes this completion script"

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
