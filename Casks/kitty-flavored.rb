cask "kitty-flavored" do
  version "0.18.3"
  sha256 "c79dd06996f93b86d2e1fd714c6627f487084b36db75595573552573305526cc"

  url "https://github.com/waltarix/kitty/releases/download/v#{version.before_comma}-custom/kitty-#{version.before_comma}.dmg"
  appcast "https://github.com/waltarix/kitty/releases.atom"
  name "kitty flavored"
  homepage "https://github.com/kovidgoyal/kitty"

  conflicts_with cask: "kitty"

  depends_on macos: ">= :sierra"
  depends_on formula: "harfbuzz"
  depends_on formula: "libpng"
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
