class Jikecarthage < Formula
    desc "Decentralized dependency manager for Cocoa"
    homepage "https://github.com/Carthage/Carthage"
    url "https://github.com/ruguoapp/Carthage.git"
    head "https://github.com/ruguoapp/Carthage.git", :shallow => false
    url "https://github.com/ruguoapp/homebrew-carthage.git"
    head "https://github.com/ruguoapp/homebrew-carthage.git", :shallow => false
  
    bottle do
      cellar :any
      sha256 "4c86ff31bf54d7ee8dad4e9921d7757c5fc6f4b62ec141e339bcfae667fb23da" => :mojave
      sha256 "99f35655d278ebe1dae617847f77ec5bbae4a8ebbe7c636c7912c53902c0e7a8" => :high_sierra
    end