class Osc52 < Formula
  desc "Access the system clipboard from anywhere using the ANSI OSC52 sequence"
  homepage "https://github.com/theimpostor/osc"
  ["0.4.8", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-linux_amd64_v2.tar.xz"
        sha256 "670356d84c35a99abd1f3b9ec914dde381008788381512e9fc7e87b61a23ecb5"
      else
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-linux_amd64_v4.tar.xz"
        sha256 "2e66e3765bf846260d0e1fdd3c0ec463ff1702d811f09e59c9e60ebde205564d"
      end
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-darwin_arm64.tar.xz"
        sha256 "486f975f3db302728aa6e8aff75016d7a7623f8334bc710d35ab1f05d6a92c6e"
      else
        url "https://github.com/waltarix/osc/releases/download/v#{v}-custom#{rev}/osc-#{v}-darwin_amd64_v3.tar.xz"
        sha256 "f57dae0d80cd2b5e8be847398a75353d7e41dd833c7a60ec2343d197ffba2278"
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
