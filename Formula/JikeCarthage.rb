class Jikecarthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/Carthage/Carthage"
  url "https://github.com/ruguoapp/homebrew-carthage.git",
      :shallow  => false
  head "https://github.com/ruguoapp/homebrew-carthage.git", :shallow => false

  bottle do
    root_url "https://github.com/ruguoapp/homebrew-carthage/releases/tag/0.33.0-j"
    cellar :any_skip_relocation
    sha256 "c7f8cd45568fca405784f51749215a3a6ad86b3c0a109ca2ac9257398fda803d" => :mojave
  end

  depends_on :xcode => ["9.4", :build]

  def install
    system "make", "prefix_install", "PREFIX=#{prefix}"
    bash_completion.install "Source/Scripts/carthage-bash-completion" => "carthage"
    zsh_completion.install "Source/Scripts/carthage-zsh-completion" => "_carthage"
    fish_completion.install "Source/Scripts/carthage-fish-completion" => "carthage.fish"
  end

  test do
    (testpath/"Cartfile").write 'github "jspahrsummers/xcconfigs"'
    system bin/"carthage", "update"
  end
end