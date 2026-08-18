class Projectorrays < Formula
  desc "Completely static, zero-dependency build of ProjectorRays"
  homepage "https://github.com/Tree4Free/ProjectorRaysNix" # 👈 Change to your fork URL
  
  # 🌟 This URL must point directly to your GitHub Release Asset tar/zip/binary
  url "https://github.com/Tree4Free/ProjectorRaysNix/releases/download/v0.1.0/projectorrays-linux.tar.gz"
  version "0.1.0"
  
  # 🌟 Run `sha256sum your-binary.tar.gz` and paste the exact cryptographic hash here
  sha256 "f06793c0dda52debf70f00a99d1ed1daaa0f3ac2cebac05bedb924bee7c1c1c0"

  def install
    # Homebrew simply takes your pre-compiled binary and moves it into its execution path
    bin.install "projectorrays"
  end

  test do
    # Simple sanity check to ensure the binary runs without dynamic library crashes
    system "#{bin}/projectorrays"
  end
end
