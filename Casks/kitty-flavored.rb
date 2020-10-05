cask "kitty-flavored" do
  version "0.19.0"
  sha256 "d81150eaac0b16ff4e85bee6ce94ffdbfb4a0512ba1f48dfd4a2ff1d4331cee8"

  url "https://github.com/waltarix/kitty/releases/download/v#{version.before_comma}-custom/kitty-#{version.before_comma}.dmg"
  appcast "https://github.com/waltarix/kitty/releases.atom"
  name "kitty flavored"
  desc "Cross-platform, fast, feature full, GPU based terminal emulator"
  homepage "https://github.com/kovidgoyal/kitty"

  conflicts_with cask: "kitty"

  depends_on macos: ">= :sierra"
  depends_on formula: "harfbuzz"
  depends_on formula: "libpng"
  depends_on formula: "little-cms2"
  depends_on formula: "python"

  app "kitty.app"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/kitty.wrapper.sh"
  binary shimscript, target: "kitty"

  preflight do
    IO.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{appdir}/kitty.app/Contents/MacOS/kitty' "$@"
    EOS
  end

  zap trash: [
    "~/.config/kitty",
    "~/Library/Preferences/kitty",
    "~/Library/Saved Application State/net.kovidgoyal.kitty.savedState",
  ]
end
