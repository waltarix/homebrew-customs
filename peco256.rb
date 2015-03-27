require "language/go"

class ::Bottle
  class Filename
    alias :prefix_orig :prefix

    def prefix
      if name == "peco256"
        "#{name}-#{version}"
      else
        prefix_orig
      end
    end
  end
end

class Peco256 < Formula
  PECO_REVISION = "17cfcc983710a2e276d49e1ac2ff2c07aed8e338"

  homepage "https://github.com/waltarix/peco"
  url "https://github.com/waltarix/peco.git",
    :branch   => '256color',
    :revision => PECO_REVISION
  version "0.3.2"

  conflicts_with "peco"

  bottle do
    cellar :any
    root_url "https://github.com/waltarix/peco/releases/download/v0.3.2-256color"
    sha1 "94b230fc6c67c1a4d1e523ab6fca4ee6293d52e4" => :yosemite
    sha1 "94b230fc6c67c1a4d1e523ab6fca4ee6293d52e4" => :mavericks
    sha1 "94b230fc6c67c1a4d1e523ab6fca4ee6293d52e4" => :mountain_lion
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
      :revision => PECO_REVISION
  end

  depends_on "go" => :build

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
