class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.17.5.tar.gz"
  sha256 "de3b39758e01b19bbc04ee0d5107e14052d3a32ce8f40d4a63d0ed311394f7ee"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "fbef178808dd3cee3b36ea3256579bc759e6516f87c4b8b2be00ad404ce14d4f" => :mojave
    sha256 "7307a392d1869453b5dbfa86b4b0bb4b1e8e6178d12fd928b82e9f8cfde3926d" => :high_sierra
    sha256 "490018ace4f9d99a470af3be3a409c793c1551fe72a6be2ad6e766dd594fa282" => :sierra
  end

  depends_on "glide" => :build
  depends_on "go" => :build

  def pour_bottle?
    false
  end

  patch :DATA

  def install
    ENV["GLIDE_HOME"] = buildpath/"glide_home"
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/junegunn").mkpath
    ln_s buildpath, buildpath/"src/github.com/junegunn/fzf"
    system "glide", "install"

    inreplace buildpath/"vendor/github.com/mattn/go-runewidth/runewidth.go",
      "{0x2580, 0x258F}, ", ""

    system "go", "build", "-o", bin/"fzf", "-ldflags", "-X main.revision=brew"

    prefix.install "install", "uninstall"
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    (prefix/"plugin").install "plugin/fzf.vim"
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
    bin.install "bin/fzf-tmux"
  end

  def caveats; <<~EOS
    To install useful keybindings and fuzzy completion:
      #{opt_prefix}/install

    To use fzf in Vim, add the following line to your .vimrc:
      set rtp+=#{opt_prefix}
  EOS
  end

  test do
    (testpath/"list").write %w[hello world].join($INPUT_RECORD_SEPARATOR)
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end

__END__
diff --git a/src/result.go b/src/result.go
index 289d83a..6b7a8c5 100644
--- a/src/result.go
+++ b/src/result.go
@@ -95,7 +95,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 	if len(itemColors) == 0 {
 		var offsets []colorOffset
 		for _, off := range matchOffsets {
-			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr})
+			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr | tui.Bold})
 		}
 		return offsets
 	}
@@ -139,7 +139,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 		if curr != 0 && idx > start {
 			if curr == -1 {
 				colors = append(colors, colorOffset{
-					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr})
+					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr | tui.Bold})
 			} else {
 				ansi := itemColors[curr-1]
 				fg := ansi.color.fg
diff --git a/src/terminal.go b/src/terminal.go
index cae349d..bb5b88d 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -703,8 +703,8 @@ func (t *Terminal) printPrompt() {
 	t.window.CPrint(tui.ColPrompt, t.strong, t.prompt)
 
 	before, after := t.updatePromptOffset()
-	t.window.CPrint(tui.ColNormal, t.strong, string(before))
-	t.window.CPrint(tui.ColNormal, t.strong, string(after))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(before))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(after))
 }
 
 func (t *Terminal) printInfo() {
@@ -841,7 +841,7 @@ func (t *Terminal) printItem(result Result, line int, i int, current bool) {
 		} else {
 			t.window.CPrint(tui.ColCurrent, t.strong, " ")
 		}
-		newLine.width = t.printHighlighted(result, t.strong, tui.ColCurrent, tui.ColCurrentMatch, true, true)
+		newLine.width = t.printHighlighted(result, tui.AttrRegular, tui.ColCurrent, tui.ColCurrentMatch, true, true)
 	} else {
 		if selected {
 			t.window.CPrint(tui.ColSelected, t.strong, ">")
