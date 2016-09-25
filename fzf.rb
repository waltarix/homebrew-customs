require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.15.1.tar.gz"
  sha256 "d48e7fd63b36a89b0187775eee3dae76992070cba62587d94303d39ecfa7d022"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d2af56eed70b92ccb89ff518e6d87873daa7971cb147dca6292606cd277b62c4" => :sierra
    sha256 "51c9408349e2576d6c3982dea4f9ede66753c9b193318344f5cbd98a25493f2f" => :el_capitan
    sha256 "ae94ccca1c82fff3c2ed9f734bb9deaedbd28165ff98c370996bef83eb5dac69" => :yosemite
  end

  def pour_bottle?
    false
  end

  patch :DATA

  depends_on "go" => :build

  go_resource "github.com/junegunn/go-shellwords" do
    url "https://github.com/junegunn/go-shellwords.git",
        :revision => "35d512af75e283aae4ca1fc3d44b159ed66189a4"
  end

  go_resource "github.com/junegunn/go-runewidth" do
    url "https://github.com/junegunn/go-runewidth.git",
        :revision => "63c378b851290989b19ca955468386485f118c65"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/junegunn"
    ln_s buildpath, buildpath/"src/github.com/junegunn/fzf"
    Language::Go.stage_deps resources, buildpath/"src"

    cd buildpath/"src/fzf" do
      system "go", "build"
      bin.install "fzf"
    end

    prefix.install %w[install uninstall LICENSE]
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    (prefix/"plugin").install "plugin/fzf.vim"
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
    bin.install "bin/fzf-tmux"
  end

  def caveats; <<-EOS.undent
    To install useful keybindings and fuzzy completion:
      #{opt_prefix}/install

    To use fzf in Vim, add the following line to your .vimrc:
      set rtp+=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"list").write %w[hello world].join($/)
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end

__END__
diff --git a/src/terminal.go b/src/terminal.go
index 0e9436a..e75dcac 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -517,7 +517,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(C.ColPrompt, true, t.prompt)
-	t.window.CPrint(C.ColNormal, true, string(t.input))
+	t.window.CPrint(C.ColNormal, false, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -617,7 +617,7 @@ func (t *Terminal) printItem(result *Result, i int, current bool) {
 		} else {
 			t.window.CPrint(C.ColCurrent, true, " ")
 		}
-		t.printHighlighted(result, true, C.ColCurrent, C.ColCurrentMatch, true)
+		t.printHighlighted(result, false, C.ColCurrent, C.ColCurrentMatch, true)
 	} else {
 		if selected {
 			t.window.CPrint(C.ColSelected, true, ">")
@@ -705,7 +705,7 @@ func (t *Terminal) printHighlighted(result *Result, bold bool, col1 int, col2 in
 		maxe = util.Max(maxe, int(offset[1]))
 	}
 
-	offsets := result.colorOffsets(charOffsets, col2, bold, current)
+	offsets := result.colorOffsets(charOffsets, col2, true, current)
 	maxWidth := t.window.Width - 3
 	maxe = util.Constrain(maxe+util.Min(maxWidth/2-2, t.hscrollOff), 0, len(text))
 	if overflow(text, maxWidth) {
