class Jikecarthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/Carthage/Carthage"
  url "https://github.com/ruguoapp/homebrew-carthage.git",
      :shallow  => false
  head "https://github.com/ruguoapp/homebrew-carthage.git", :shallow => false

  bottle do
    cellar :any
    root_url "https://github.com/ruguoapp/homebrew-carthage/releases/download/0.32.0/"
    sha256 "9c3671054b7db0f6e3b95b00956666bef47dd3930f05be9e57b6208732502efe" => :mojave
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