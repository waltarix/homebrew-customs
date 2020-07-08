cask 'kitty-flavored' do
  version '0.18.1,r1'
  sha256 '0bd7ef0b8f5f29207355cda753ffdb79fb9b6c8b29ec12103a0f5ed16bd5f596'

  url "https://github.com/waltarix/kitty/releases/download/v#{version.before_comma}-custom-r1/kitty-#{version.before_comma}.dmg"
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
