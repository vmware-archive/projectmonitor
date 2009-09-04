path = File.join(File.dirname(__FILE__), 'development.rb')
eval(IO.read(path), binding, path)
