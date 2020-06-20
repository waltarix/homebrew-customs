cask 'kitty-flavored' do
  version '0.17.4'
  sha256 '10b8ecfe8ef1aabed2cf64287b4ef13c2cb5dd88530234d855af0570505226c7'

  url "https://github.com/waltarix/kitty/releases/download/v#{version}-custom-r1/kitty-#{version}.dmg"
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
