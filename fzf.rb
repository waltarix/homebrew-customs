class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.21.1.tar.gz"
  sha256 "47adf138f17c45d390af81958bdff6f92157d41e2c4cb13773df078b905cdaf4"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "733f79496c3246979ca05eeb5677a5fd9e8ec532e69e8b2012102cacddba8ae6" => :catalina
    sha256 "3c03bb9715be153a0f776d06cf4acd436ad4faa4266f7bd875a0d37594291516" => :mojave
    sha256 "d15a616156eb92071f1cfc50f10366532af92ca1635d309162141ad67f785865" => :high_sierra
  end

  depends_on "go" => :build

  def pour_bottle?
    false
  end

  patch :DATA

  def install
    gopath = HOMEBREW_CACHE/"go_cache"
    ENV["GOPATH"] = gopath
    system "go", "clean", "--modcache"
    system "go", "mod", "tidy"
    runewidth_dir = gopath/"pkg/mod/github.com/mattn/go-runewidth@v0.0.8"
    chmod 0755, runewidth_dir
    inreplace runewidth_dir/"runewidth_table.go", "{0x2580, 0x258F}, ", ""

    system "go", "build", "-o", bin/"fzf", "-ldflags", "-X main.revision=brew"

    prefix.install "install", "uninstall"
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    (prefix/"plugin").install "plugin/fzf.vim"
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
    bin.install "bin/fzf-tmux"
  end

  def caveats
    <<~EOS
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
index be325cb..6b06db8 100644
--- a/src/result.go
+++ b/src/result.go
@@ -94,7 +94,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 	if len(itemColors) == 0 {
 		var offsets []colorOffset
 		for _, off := range matchOffsets {
-			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr})
+			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr | tui.Bold})
 		}
 		return offsets
 	}
@@ -138,7 +138,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 		if curr != 0 && idx > start {
 			if curr == -1 {
 				colors = append(colors, colorOffset{
-					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr})
+					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr | tui.Bold})
 			} else {
 				ansi := itemColors[curr-1]
 				fg := ansi.color.fg
diff --git a/src/terminal.go b/src/terminal.go
index cb8f13c..8eed011 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -765,8 +765,8 @@ func (t *Terminal) printPrompt() {
 	t.window.CPrint(tui.ColPrompt, t.strong, t.prompt)
 
 	before, after := t.updatePromptOffset()
-	t.window.CPrint(tui.ColNormal, t.strong, string(before))
-	t.window.CPrint(tui.ColNormal, t.strong, string(after))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(before))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(after))
 }
 
 func (t *Terminal) printInfo() {
@@ -911,7 +911,7 @@ func (t *Terminal) printItem(result Result, line int, i int, current bool) {
 		} else {
 			t.window.CPrint(tui.ColCurrentSelected, t.strong, t.markerEmpty)
 		}
-		newLine.width = t.printHighlighted(result, t.strong, tui.ColCurrent, tui.ColCurrentMatch, true, true)
+		newLine.width = t.printHighlighted(result, tui.AttrRegular, tui.ColCurrent, tui.ColCurrentMatch, true, true)
 	} else {
 		t.window.CPrint(tui.ColCursor, t.strong, label)
 		if selected {
