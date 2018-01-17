# For platform specific configuration

if platform = document.body.className.match(/platform-(darwin|win32|linux)/)?[1]
  path = require 'path'
  CSON = require path.join atom.getLoadSettings().resourcePath, '/node_modules/season'
  config = CSON.readFileSync atom.config.getUserConfigPath()
  if config[platform]?
    for own scopeSelector, scopeConfig of config[platform]
      for own namespace, namespaceConfig of scopeConfig
        for own key, value of namespaceConfig
          atom.config.set "#{namespace}.#{key}", value, scopeSelector
