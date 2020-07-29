cask 'kitty-flavored' do
  version '0.18.2'
  sha256 '64f3753f284635890c4554cbaecc81616670e58fc97bb3e3a3566a4bffee6d22'

  url "https://github.com/waltarix/kitty/releases/download/v#{version.before_comma}-custom/kitty-#{version.before_comma}.dmg"
  appcast 'https://github.com/waltarix/kitty/releases.atom'
  name 'kitty flavored'
  homepage 'https://github.com/kovidgoyal/kitty'

  conflicts_with cask: 'kitty'

  depends_on macos: '>= :sierra'
  depends_on formula: 'harfbuzz'
  depends_on formula: 'libpng'
  depends_on formula: 'python'

  app 'kitty.app'
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/kitty.wrapper.sh"
  binary shimscript, target: 'kitty'

  preflight do
    IO.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{appdir}/kitty.app/Contents/MacOS/kitty' "$@"
    EOS
  end

  zap trash: [
               '~/.config/kitty',
               '~/Library/Preferences/kitty',
               '~/Library/Saved Application State/net.kovidgoyal.kitty.savedState',
             ]
end
