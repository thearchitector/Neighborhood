#
# The installation script below does not use double quotes, string interpolation, or
# backticks. This is because Windows Powershell does not escape them when content
# is downloaded from 'curl' or 'wget', meaning the commands simply break.
# Annoying, yes. But hey, 'I like you just the way you are'.
#

abort('Neighborhood currently only manages cross-platform requirments of your gemfiles. Gemfile.lock is required for this.') if !File.exists?('Gemfile.lock')
abort('Neighborhood can only help you if you install it inside a git repository!') if !Dir.exist?('.git/hooks')
abort('To maintain your sanity, Neighborhood has stopped itself from overwriting your existing pre-commit git hook.') if File.exists?('.git/hooks/pre-commit')

require 'open3'
require 'rbconfig'
require 'open-uri'
require 'tmpdir'
require 'digest'
require 'securerandom'

valid, c = Open3.capture2('gem list bundler -i')

abort('Neighborhood requires the Bundler gem to be installed. Yet, Gemfile.lock exists! Stop playing around...') if valid != 'true'
puts '[Neighborhood] Installing the cross-platform neighborhood watch...'
puts '  - Fetching git hook...'

hook = [Dir.tmpdir(), '/', Digest::MD5.hexdigest(SecureRandom.uuid), '.rb'].join

IO.copy_stream(open('https://raw.githubusercontent.com/TheMasterGabriel/Neighborhood/master/scripts/neighborly'), hook)

puts '  - Configuring the hook to your system...'
config = RbConfig::CONFIG
ruby_exe = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']

File.open('.git/hooks/pre-commit', 'w') do |f|
    f.puts('#!' + ruby_exe.gsub(/ /, '\ '))
    f.puts('')

    File.foreach(hook) do |line|
        f.puts(line)
    end
end

puts '  - Git hook installed successfully!'
puts '  - Configuring your Gemlock.file for cross-platform development...'

Open3.capture2('bundle lock --add-platform=ruby')

puts '  - Successfully added the ruby platform to your Gemfile.lock...'
puts '  - Running git hook...'
exec('ruby', '.git/hooks/pre-commit')