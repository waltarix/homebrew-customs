require "language/go"

class Peco256 < Formula
  homepage "https://github.com/waltarix/peco"
  url "https://github.com/waltarix/peco.git",
    :branch   => '256color',
    :revision => "17cfcc983710a2e276d49e1ac2ff2c07aed8e338"
  version "0.3.2"

  conflicts_with "peco"

  bottle do
    cellar :any
    sha1 "09dcbdd0a4cc55c36cc4578f237ac19c360651a1" => :yosemite
    sha1 "eaf5161f6ce66b67a026825a4f3047974d147500" => :mavericks
    sha1 "61e853d89cd34129cf0e010c36939491c3b11329" => :mountain_lion
  end

  go_resource "github.com/jessevdk/go-flags" do
    url "https://github.com/jessevdk/go-flags.git",
      :revision => "8ec9564882e7923e632f012761c81c46dcf5bec1"
  end

  go_resource "github.com/mattn/go-runewidth" do
    url "https://github.com/mattn/go-runewidth.git",
      :revision => "58a0da4ed7b321c9b5dfeffb7e03ee188fae1c60"
  end

  go_resource "github.com/nsf/termbox-go" do
    url "https://github.com/nsf/termbox-go.git",
      :revision => "10f14d7408b64a659b7c694a771f5006952d336c"
  end

  go_resource "github.com/google/btree" do
    url "https://github.com/google/btree.git",
      :revision => "0c05920fc3d98100a5e3f7fd339865a6e2aaa671"
  end

  go_resource "github.com/peco/peco" do
    url "https://github.com/waltarix/peco.git",
      :branch   => '256color',
      :revision => "17cfcc983710a2e276d49e1ac2ff2c07aed8e338"
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
