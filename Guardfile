guard :bundler do
  watch('Gemfile')
end

guard :shell do
  watch('postgres.rb') { |f| system("./postgres.rb") }
  watch('elasticsearch.rb') { |f| system("./elasticsearch.rb") }
end
