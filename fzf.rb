require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.15.8.tar.gz"
  sha256 "f02ba45837e8583a3aa4e54a7d0b7d493f5314be6923ca80a639b43d6c0f4a4f"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "20cf6612cb96c5028e49c2a29ae046326e6b21e60a6abcf537b8a92fc6851aed" => :sierra
    sha256 "3e7ce8072c4fe888b085361733f78783a69b3315fd9a81dbf1d05db09361bd2f" => :el_capitan
    sha256 "9cf69e99ac4f27bf311561bcf790be45ae990027cadefb0071d52ce5a6680181" => :yosemite
  end

  def pour_bottle?
    false
  end

  patch :DATA

  depends_on "go" => :build

  go_resource "github.com/junegunn/go-isatty" do
    url "https://github.com/junegunn/go-isatty.git",
        :revision => "66b8e73f3f5cda9f96b69efd03dd3d7fc4a5cdb8"
  end

  go_resource "github.com/junegunn/go-runewidth" do
    url "https://github.com/junegunn/go-runewidth.git",
        :revision => "63c378b851290989b19ca955468386485f118c65"
  end

  go_resource "github.com/junegunn/go-shellwords" do
    url "https://github.com/junegunn/go-shellwords.git",
        :revision => "35d512af75e283aae4ca1fc3d44b159ed66189a4"
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
index 315d9f1..0a874b0 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -540,7 +540,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(tui.ColPrompt, t.strong, t.prompt)
-	t.window.CPrint(tui.ColNormal, t.strong, string(t.input))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -641,7 +641,7 @@ func (t *Terminal) printItem(result *Result, i int, current bool) {
 		} else {
 			t.window.CPrint(tui.ColCurrent, t.strong, " ")
 		}
-		t.printHighlighted(result, t.strong, tui.ColCurrent, tui.ColCurrentMatch, true)
+		t.printHighlighted(result, tui.AttrRegular, tui.ColCurrent, tui.ColCurrentMatch, true)
 	} else {
 		if selected {
 			t.window.CPrint(tui.ColSelected, t.strong, ">")
@@ -729,7 +729,7 @@ func (t *Terminal) printHighlighted(result *Result, attr tui.Attr, col1 tui.Colo
 		maxe = util.Max(maxe, int(offset[1]))
 	}
 
-	offsets := result.colorOffsets(charOffsets, t.theme, col2, attr, current)
+	offsets := result.colorOffsets(charOffsets, t.theme, col2, tui.Bold, current)
 	maxWidth := t.window.Width - 3
 	maxe = util.Constrain(maxe+util.Min(maxWidth/2-2, t.hscrollOff), 0, len(text))
 	if overflow(text, maxWidth) {
