class Firecracker < Formula
  desc "Secure and fast microVMs for serverless computing"
  homepage "https://firecracker-microvm.github.io"
  license "Apache-2.0"

  # Firecracker only runs on Linux (it needs KVM). Both URLs are updated
  # automatically by scripts/update-formula.sh via GitHub Actions.
  depends_on :linux

  on_intel do
    url "https://github.com/firecracker-microvm/firecracker/releases/download/v1.17.0/firecracker-v1.17.0-x86_64.tgz"
    sha256 "06094a1108ae9e82aa4c23a775aa92758f53f1175d422270d9d6162cb9ade558"
  end

  on_arm do
    url "https://github.com/firecracker-microvm/firecracker/releases/download/v1.17.0/firecracker-v1.17.0-aarch64.tgz"
    sha256 "e351ebe4f7a16b5873bbd51005d2e6767103cff4d5ebc829df2d3f95a93e2256"
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    arch = Hardware::CPU.intel? ? "x86_64" : "aarch64"
    suffix = "-v#{version}-#{arch}"

    # Main binaries, installed without the version/arch suffix
    %w[firecracker jailer seccompiler-bin rebase-snap snapshot-editor cpu-template-helper].each do |name|
      bin.install "#{name}#{suffix}" => name
    end

    # Seccomp filter, bundled CPU templates and the API spec
    pkgshare.install "seccomp-filter#{suffix}.json" => "seccomp-filter.json"
    (pkgshare/"cpu-templates").install Dir["*-v#{version}.json"]
    pkgshare.install "firecracker_spec-v#{version}.yaml" => "firecracker_spec.yaml"

    doc.install "NOTICE", "THIRD-PARTY"
  end

  def caveats
    <<~EOS
      Firecracker requires access to /dev/kvm. In production, run it through the jailer:
        jailer --id <id> --exec-file #{opt_bin}/firecracker --uid <uid> --gid <gid>

      Bundled CPU templates and the seccomp filter are in:
        #{opt_pkgshare}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/firecracker --version")
    assert_match version.to_s, shell_output("#{bin}/jailer --version")
  end
end
