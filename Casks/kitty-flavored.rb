cask 'kitty-flavored' do
  version '0.18.0'
  sha256 '88738e031659eaf5dd17bbed76e5d4fa21e4c38484780562db0360555ee36bc4'

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
