desc "Mac SDK and XCode license agreement"
task :agree_xcodebuild_license do
  sh "sudo xcodebuild -license"
end

desc "Install xcode commandline tool"
task :install_xcode_commandline_tool do
  sh "xcode-select --install"
end

desc "Install homebrew"
task :install_homebrew do
  begin
    sh "hash brew"
    puts "Homebrew is already installed"
  rescue
    puts "Install Homebrew"
    sh 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  end
end

desc "Update homebrew repository"
task :prepare_homebrew => :install_homebrew do
  sh "brew update"
end

namespace :setup do
  desc "Setup xcode commandline tool"
  task xcode: [:agree_xcodebuild_license, :install_xcode_commandline_tool] do
  end

  desc "Setup Homebrew"
  task homebrew: [:install_homebrew, :prepare_homebrew] do
  end

  desc "Restore settings"
  task :mackup do
    sh "mackup restore"
  end
end
