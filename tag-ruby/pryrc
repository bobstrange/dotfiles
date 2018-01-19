Pry.config.editor = 'vim --noplugin'

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'b', 'break'
  Pry.commands.alias_command 'bda', 'break --disable-all'
end

if defined?(Rails::Console)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
