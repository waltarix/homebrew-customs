class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  url "https://github.com/neovim/neovim/archive/v0.2.2.tar.gz"
  sha256 "a838ee07cc9a2ef8ade1b31a2a4f2d5e9339e244ade68e64556c1f4b40ccc5ed"
  revision 2
  head "https://github.com/neovim/neovim.git"

  bottle do
    sha256 "5511bf90172647f7b0eda6587a5b1e43cee22401bed32a40344f9205d32be48e" => :high_sierra
    sha256 "e05a7844a25e252ca9460331cc4522eeda7c213124306324cbbd4fb9e45b10b3" => :sierra
    sha256 "d5d62f862a89868655f9d0ab12a8742e4ec605a96a7c44a7e23cfe2961fb5542" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "lua@5.1" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "jemalloc"
  depends_on "libtermkey"
  depends_on "libuv"
  depends_on "libvterm"
  depends_on "luajit"
  depends_on "msgpack"
  depends_on "unibilium"
  depends_on "python" if MacOS.version <= :snow_leopard

  resource "lpeg" do
    url "https://luarocks.org/manifests/gvvaughan/lpeg-1.0.1-1.src.rock", :using => :nounzip
    sha256 "149be31e0155c4694f77ea7264d9b398dd134eca0d00ff03358d91a6cfb2ea9d"
  end

  resource "mpack" do
    url "https://luarocks.org/manifests/tarruda/mpack-1.0.6-0.src.rock", :using => :nounzip
    sha256 "9068d9d3f407c72a7ea18bc270b0fa90aad60a2f3099fa23d5902dd71ea4cd5f"
  end

  patch :DATA

  def pour_bottle?
    false
  end

  def install
    resources.each do |r|
      r.stage(buildpath/"deps-build/build/src/#{r.name}")
    end

    ENV.prepend_path "LUA_PATH", "#{buildpath}/deps-build/share/lua/5.1/?.lua"
    ENV.prepend_path "LUA_CPATH", "#{buildpath}/deps-build/lib/lua/5.1/?.so"

    cd "deps-build" do
      system "luarocks-5.1", "build", "build/src/lpeg/lpeg-1.0.1-1.src.rock", "--tree=."
      system "luarocks-5.1", "build", "build/src/mpack/mpack-1.0.6-0.src.rock", "--tree=."
      system "cmake", "../third-party", "-DUSE_BUNDLED=OFF", *std_cmake_args
      system "make"
    end

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.txt").write("Hello World from Vim!!")
    system bin/"nvim", "--headless", "-i", "NONE", "-u", "NONE",
                       "+s/Vim/Neovim/g", "+wq", "test.txt"
    assert_equal "Hello World from Neovim!!", (testpath/"test.txt").read.chomp
  end
end

__END__
diff --git a/unicode/EastAsianWidth.txt b/unicode/EastAsianWidth.txt
index 0d3129bb0..8048775e6 100644
--- a/unicode/EastAsianWidth.txt
+++ b/unicode/EastAsianWidth.txt
@@ -1137,7 +1137,7 @@
 254C..254F;N     # So     [4] BOX DRAWINGS LIGHT DOUBLE DASH HORIZONTAL..BOX DRAWINGS HEAVY DOUBLE DASH VERTICAL
 2550..2573;A     # So    [36] BOX DRAWINGS DOUBLE HORIZONTAL..BOX DRAWINGS LIGHT DIAGONAL CROSS
 2574..257F;N     # So    [12] BOX DRAWINGS LIGHT LEFT..BOX DRAWINGS HEAVY UP AND LIGHT DOWN
-2580..258F;A     # So    [16] UPPER HALF BLOCK..LEFT ONE EIGHTH BLOCK
+2580..258F;H     # So    [16] UPPER HALF BLOCK..LEFT ONE EIGHTH BLOCK
 2590..2591;N     # So     [2] RIGHT HALF BLOCK..LIGHT SHADE
 2592..2595;A     # So     [4] MEDIUM SHADE..RIGHT ONE EIGHTH BLOCK
 2596..259F;N     # So    [10] QUADRANT LOWER LEFT..QUADRANT UPPER RIGHT AND LOWER LEFT AND LOWER RIGHT
@@ -2271,95 +2271,7 @@ FFFD;A           # So         REPLACEMENT CHARACTER
 1EEA5..1EEA9;N   # Lo     [5] ARABIC MATHEMATICAL DOUBLE-STRUCK WAW..ARABIC MATHEMATICAL DOUBLE-STRUCK YEH
 1EEAB..1EEBB;N   # Lo    [17] ARABIC MATHEMATICAL DOUBLE-STRUCK LAM..ARABIC MATHEMATICAL DOUBLE-STRUCK GHAIN
 1EEF0..1EEF1;N   # Sm     [2] ARABIC MATHEMATICAL OPERATOR MEEM WITH HAH WITH TATWEEL..ARABIC MATHEMATICAL OPERATOR HAH WITH DAL
-1F000..1F003;N   # So     [4] MAHJONG TILE EAST WIND..MAHJONG TILE NORTH WIND
-1F004;W          # So         MAHJONG TILE RED DRAGON
-1F005..1F02B;N   # So    [39] MAHJONG TILE GREEN DRAGON..MAHJONG TILE BACK
-1F030..1F093;N   # So   [100] DOMINO TILE HORIZONTAL BACK..DOMINO TILE VERTICAL-06-06
-1F0A0..1F0AE;N   # So    [15] PLAYING CARD BACK..PLAYING CARD KING OF SPADES
-1F0B1..1F0BF;N   # So    [15] PLAYING CARD ACE OF HEARTS..PLAYING CARD RED JOKER
-1F0C1..1F0CE;N   # So    [14] PLAYING CARD ACE OF DIAMONDS..PLAYING CARD KING OF DIAMONDS
-1F0CF;W          # So         PLAYING CARD BLACK JOKER
-1F0D1..1F0F5;N   # So    [37] PLAYING CARD ACE OF CLUBS..PLAYING CARD TRUMP-21
-1F100..1F10A;A   # No    [11] DIGIT ZERO FULL STOP..DIGIT NINE COMMA
-1F10B..1F10C;N   # No     [2] DINGBAT CIRCLED SANS-SERIF DIGIT ZERO..DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT ZERO
-1F110..1F12D;A   # So    [30] PARENTHESIZED LATIN CAPITAL LETTER A..CIRCLED CD
-1F12E;N          # So         CIRCLED WZ
-1F130..1F169;A   # So    [58] SQUARED LATIN CAPITAL LETTER A..NEGATIVE CIRCLED LATIN CAPITAL LETTER Z
-1F16A..1F16B;N   # So     [2] RAISED MC SIGN..RAISED MD SIGN
-1F170..1F18D;A   # So    [30] NEGATIVE SQUARED LATIN CAPITAL LETTER A..NEGATIVE SQUARED SA
-1F18E;W          # So         NEGATIVE SQUARED AB
-1F18F..1F190;A   # So     [2] NEGATIVE SQUARED WC..SQUARE DJ
-1F191..1F19A;W   # So    [10] SQUARED CL..SQUARED VS
-1F19B..1F1AC;A   # So    [18] SQUARED THREE D..SQUARED VOD
-1F1E6..1F1FF;N   # So    [26] REGIONAL INDICATOR SYMBOL LETTER A..REGIONAL INDICATOR SYMBOL LETTER Z
-1F200..1F202;W   # So     [3] SQUARE HIRAGANA HOKA..SQUARED KATAKANA SA
-1F210..1F23B;W   # So    [44] SQUARED CJK UNIFIED IDEOGRAPH-624B..SQUARED CJK UNIFIED IDEOGRAPH-914D
-1F240..1F248;W   # So     [9] TORTOISE SHELL BRACKETED CJK UNIFIED IDEOGRAPH-672C..TORTOISE SHELL BRACKETED CJK UNIFIED IDEOGRAPH-6557
-1F250..1F251;W   # So     [2] CIRCLED IDEOGRAPH ADVANTAGE..CIRCLED IDEOGRAPH ACCEPT
-1F260..1F265;W   # So     [6] ROUNDED SYMBOL FOR FU..ROUNDED SYMBOL FOR CAI
-1F300..1F320;W   # So    [33] CYCLONE..SHOOTING STAR
-1F321..1F32C;N   # So    [12] THERMOMETER..WIND BLOWING FACE
-1F32D..1F335;W   # So     [9] HOT DOG..CACTUS
-1F336;N          # So         HOT PEPPER
-1F337..1F37C;W   # So    [70] TULIP..BABY BOTTLE
-1F37D;N          # So         FORK AND KNIFE WITH PLATE
-1F37E..1F393;W   # So    [22] BOTTLE WITH POPPING CORK..GRADUATION CAP
-1F394..1F39F;N   # So    [12] HEART WITH TIP ON THE LEFT..ADMISSION TICKETS
-1F3A0..1F3CA;W   # So    [43] CAROUSEL HORSE..SWIMMER
-1F3CB..1F3CE;N   # So     [4] WEIGHT LIFTER..RACING CAR
-1F3CF..1F3D3;W   # So     [5] CRICKET BAT AND BALL..TABLE TENNIS PADDLE AND BALL
-1F3D4..1F3DF;N   # So    [12] SNOW CAPPED MOUNTAIN..STADIUM
-1F3E0..1F3F0;W   # So    [17] HOUSE BUILDING..EUROPEAN CASTLE
-1F3F1..1F3F3;N   # So     [3] WHITE PENNANT..WAVING WHITE FLAG
-1F3F4;W          # So         WAVING BLACK FLAG
-1F3F5..1F3F7;N   # So     [3] ROSETTE..LABEL
-1F3F8..1F3FA;W   # So     [3] BADMINTON RACQUET AND SHUTTLECOCK..AMPHORA
-1F3FB..1F3FF;W   # Sk     [5] EMOJI MODIFIER FITZPATRICK TYPE-1-2..EMOJI MODIFIER FITZPATRICK TYPE-6
-1F400..1F43E;W   # So    [63] RAT..PAW PRINTS
-1F43F;N          # So         CHIPMUNK
-1F440;W          # So         EYES
-1F441;N          # So         EYE
-1F442..1F4FC;W   # So   [187] EAR..VIDEOCASSETTE
-1F4FD..1F4FE;N   # So     [2] FILM PROJECTOR..PORTABLE STEREO
-1F4FF..1F53D;W   # So    [63] PRAYER BEADS..DOWN-POINTING SMALL RED TRIANGLE
-1F53E..1F54A;N   # So    [13] LOWER RIGHT SHADOWED WHITE CIRCLE..DOVE OF PEACE
-1F54B..1F54E;W   # So     [4] KAABA..MENORAH WITH NINE BRANCHES
-1F54F;N          # So         BOWL OF HYGIEIA
-1F550..1F567;W   # So    [24] CLOCK FACE ONE OCLOCK..CLOCK FACE TWELVE-THIRTY
-1F568..1F579;N   # So    [18] RIGHT SPEAKER..JOYSTICK
-1F57A;W          # So         MAN DANCING
-1F57B..1F594;N   # So    [26] LEFT HAND TELEPHONE RECEIVER..REVERSED VICTORY HAND
-1F595..1F596;W   # So     [2] REVERSED HAND WITH MIDDLE FINGER EXTENDED..RAISED HAND WITH PART BETWEEN MIDDLE AND RING FINGERS
-1F597..1F5A3;N   # So    [13] WHITE DOWN POINTING LEFT HAND INDEX..BLACK DOWN POINTING BACKHAND INDEX
-1F5A4;W          # So         BLACK HEART
-1F5A5..1F5FA;N   # So    [86] DESKTOP COMPUTER..WORLD MAP
-1F5FB..1F5FF;W   # So     [5] MOUNT FUJI..MOYAI
-1F600..1F64F;W   # So    [80] GRINNING FACE..PERSON WITH FOLDED HANDS
-1F650..1F67F;N   # So    [48] NORTH WEST POINTING LEAF..REVERSE CHECKER BOARD
-1F680..1F6C5;W   # So    [70] ROCKET..LEFT LUGGAGE
-1F6C6..1F6CB;N   # So     [6] TRIANGLE WITH ROUNDED CORNERS..COUCH AND LAMP
-1F6CC;W          # So         SLEEPING ACCOMMODATION
-1F6CD..1F6CF;N   # So     [3] SHOPPING BAGS..BED
-1F6D0..1F6D2;W   # So     [3] PLACE OF WORSHIP..SHOPPING TROLLEY
-1F6D3..1F6D4;N   # So     [2] STUPA..PAGODA
-1F6E0..1F6EA;N   # So    [11] HAMMER AND WRENCH..NORTHEAST-POINTING AIRPLANE
-1F6EB..1F6EC;W   # So     [2] AIRPLANE DEPARTURE..AIRPLANE ARRIVING
-1F6F0..1F6F3;N   # So     [4] SATELLITE..PASSENGER SHIP
-1F6F4..1F6F8;W   # So     [5] SCOOTER..FLYING SAUCER
-1F700..1F773;N   # So   [116] ALCHEMICAL SYMBOL FOR QUINTESSENCE..ALCHEMICAL SYMBOL FOR HALF OUNCE
-1F780..1F7D4;N   # So    [85] BLACK LEFT-POINTING ISOSCELES RIGHT TRIANGLE..HEAVY TWELVE POINTED PINWHEEL STAR
-1F800..1F80B;N   # So    [12] LEFTWARDS ARROW WITH SMALL TRIANGLE ARROWHEAD..DOWNWARDS ARROW WITH LARGE TRIANGLE ARROWHEAD
-1F810..1F847;N   # So    [56] LEFTWARDS ARROW WITH SMALL EQUILATERAL ARROWHEAD..DOWNWARDS HEAVY ARROW
-1F850..1F859;N   # So    [10] LEFTWARDS SANS-SERIF ARROW..UP DOWN SANS-SERIF ARROW
-1F860..1F887;N   # So    [40] WIDE-HEADED LEFTWARDS LIGHT BARB ARROW..WIDE-HEADED SOUTH WEST VERY HEAVY BARB ARROW
-1F890..1F8AD;N   # So    [30] LEFTWARDS TRIANGLE ARROWHEAD..WHITE ARROW SHAFT WIDTH TWO THIRDS
-1F900..1F90B;N   # So    [12] CIRCLED CROSS FORMEE WITH FOUR DOTS..DOWNWARD FACING NOTCHED HOOK WITH DOT
-1F910..1F93E;W   # So    [47] ZIPPER-MOUTH FACE..HANDBALL
-1F940..1F94C;W   # So    [13] WILTED FLOWER..CURLING STONE
-1F950..1F96B;W   # So    [28] CROISSANT..CANNED FOOD
-1F980..1F997;W   # So    [24] CRAB..CRICKET
-1F9C0;W          # So         CHEESE WEDGE
-1F9D0..1F9E6;W   # So    [23] FACE WITH MONOCLE..SOCKS
+1F000..1FFFF;F   # So  [4095] EMOJIS
 20000..2A6D6;W   # Lo [42711] CJK UNIFIED IDEOGRAPH-20000..CJK UNIFIED IDEOGRAPH-2A6D6
 2A6D7..2A6FF;W   # Cn    [41] <reserved-2A6D7>..<reserved-2A6FF>
 2A700..2B734;W   # Lo  [4149] CJK UNIFIED IDEOGRAPH-2A700..CJK UNIFIED IDEOGRAPH-2B734
