# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'nanoc' do
  watch('nanoc.yaml') # Change this to config.yaml if you use the old config file name
  watch('Rules')
  watch(%r{^(content|layouts|lib)/.*$})
end

guard 'rack', port: '3000'

guard 'livereload' do
  watch(%r{^output/.*$})
end
