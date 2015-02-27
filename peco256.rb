require "language/go"

class Peco256 < Formula
  homepage "https://github.com/waltarix/peco"
  url "https://github.com/waltarix/peco.git",
    :branch   => '256color',
    :revision => "da84ee21fc30afe32757992d7f3cccbb06cc643c"
  version "0.2.12"

  conflicts_with "peco"

  bottle do
    cellar :any
    sha1 "09dcbdd0a4cc55c36cc4578f237ac19c360651a1" => :yosemite
    sha1 "eaf5161f6ce66b67a026825a4f3047974d147500" => :mavericks
    sha1 "61e853d89cd34129cf0e010c36939491c3b11329" => :mountain_lion
  end

  go_resource "github.com/jessevdk/go-flags" do
    url "https://github.com/jessevdk/go-flags.git",
      :revision => "15347ef417a300349807983f15af9e65cd2e1b3a"
  end

  go_resource "github.com/mattn/go-runewidth" do
    url "https://github.com/mattn/go-runewidth.git",
      :revision => "8adae32de8a26f36cc7acaa53051407d514bb5f0"
  end

  go_resource "github.com/nsf/termbox-go" do
    url "https://github.com/nsf/termbox-go.git",
      :revision => "9e7f2135126fcf13f331e7b24f5d66fd8e8e1690"
  end

  go_resource "github.com/peco/peco" do
    url "https://github.com/waltarix/peco.git",
      :branch   => '256color',
      :revision => "da84ee21fc30afe32757992d7f3cccbb06cc643c"
  end

  depends_on "go" => :build

  def pour_bottle?
    false
  end

  def install
    ENV["GOPATH"] = buildpath
    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build", "cmd/peco/peco.go"
    bin.install "peco"
  end

  test do
    system "#{bin}/peco", "--version"
  end
end
