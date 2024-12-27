# vim:set ft=ruby
#
Pry.config.editor = 'vim --noplugin'

require 'rbconfig'
def os
  @os ||= case RbConfig::CONFIG['host_os']
    when /darwin|mac\sos/
      :darwin
    when /linux/
      :linux
    end
end

def pbcopy(obj)
  command = case os
    when :darwin
      'pbcopy'
    when :linux
      'xclip'
    end

  IO.popen(command, 'r+') { |io| io.puts obj }
  obj
end

Pry.config.commands.command 'copy', 'Copy a text to clipboard' do |obj|
  pbcopy(obj)
end

Pry.config.commands.command 'lastcopy', 'Copy the last result to clipboard' do
  pbcopy(_pry_.last_result.chomp)
end

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'b', 'break'
  Pry.commands.alias_command 'bda', 'break --disable-all'
end

if defined?(Rails::Console) &&  defined?(ActiveRecord)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

require 'colorize'
