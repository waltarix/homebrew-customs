require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.12.0.tar.gz"
  sha256 "a0754720bda05de1547a50183acec5d8c0515a98be780c2b99d1c1385142b071"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "68e63f4286b7480d91d1c9c4585b6f07bb3f59d31263c400ea29fbd06a275244" => :el_capitan
    sha256 "3819ab5ab730be17468cbac217d25029f50303e122d3057d83abfc48093ccdf6" => :yosemite
    sha256 "dd6c9fa81962ce8a07b8b83df87973ab2ec9514a8742a6ca1e2a1a0e9dd3426e" => :mavericks
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
    man1.install "man/man1/fzf.1"
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
index 764459f..9446d79 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -402,7 +402,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	C.CPrint(C.ColPrompt, true, t.prompt)
-	C.CPrint(C.ColNormal, true, string(t.input))
+	C.CPrint(C.ColNormal, false, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -497,7 +497,7 @@ func (t *Terminal) printItem(item *Item, current bool) {
 		} else {
 			C.CPrint(C.ColCurrent, true, " ")
 		}
-		t.printHighlighted(item, true, C.ColCurrent, C.ColCurrentMatch, true)
+		t.printHighlighted(item, false, C.ColCurrent, C.ColCurrentMatch, true)
 	} else {
 		C.CPrint(C.ColCursor, true, " ")
 		if selected {
@@ -556,7 +556,7 @@ func (t *Terminal) printHighlighted(item *Item, bold bool, col1 int, col2 int, c
 	// Overflow
 	text := make([]rune, len(item.text))
 	copy(text, item.text)
-	offsets := item.colorOffsets(col2, bold, current)
+	offsets := item.colorOffsets(col2, true, current)
 	maxWidth := C.MaxX() - 3 - t.marginInt[1] - t.marginInt[3]
 	fullWidth := displayWidth(text)
 	if fullWidth > maxWidth {
