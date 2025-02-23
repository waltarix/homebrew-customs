class Osc < Formula
  desc "Access the system clipboard from anywhere using the ANSI OSC52 sequence"
  homepage "https://github.com/theimpostor/osc"
  ["0.4.7", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-linux_amd64_v2.tar.xz"
        sha256 "8bc82add82a910e797329a0527f29e6145e55db49576e38fd10daed105bb1629"
      else
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-linux_amd64_v4.tar.xz"
        sha256 "9dd5ea09eb40b58fe6d20a78432bb17551ef72da7f0c891fcf5ef5659ffab84f"
      end
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-darwin_arm64.tar.xz"
        sha256 "11794b8e4da1f94057606013661928657438b1a7fa67d12e72d9e884f170f758"
      else
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-darwin_amd64_v3.tar.xz"
        sha256 "4e0582e429c56590169585339c1b1adacc67d7ce1a504f935c432d237656d9d1"
      end
    end
    version v
    revision r if r
  end
  license "MIT"

  def install
    bin.install "osc"
    generate_completions_from_executable(bin/"osc", "completion")
  end

  test do
    assert_match /\Av#{version}/, shell_output("#{bin}/osc version")
  end
end
