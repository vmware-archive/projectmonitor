guard 'coffeescript', input: 'spec/javascripts', output: 'spec/javascripts/compiled'

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|sass|scss|js|html|coffee|eco))).*}) { |m| "/assets/#{m[3]}" }
end
