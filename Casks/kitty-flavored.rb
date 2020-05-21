cask 'kitty-flavored' do
  version '0.17.4'
  sha256 '396052aa4112000a9e5cac2b358e00c163679d3bf4a729170dd48d02dc67bd21'

  url "https://github.com/waltarix/kitty/releases/download/v#{version}-custom/kitty-#{version}.dmg"
  appcast 'https://github.com/waltarix/kitty/releases.atom'
  name 'kitty flavored'
  homepage 'https://github.com/kovidgoyal/kitty'

  conflicts_with cask: 'kitty'

  depends_on macos: '>= :sierra'

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
