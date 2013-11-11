guard :bundler do
  watch('Gemfile')
end

guard :shell, all_on_start: true do
  watch('postgres.rb') { |f| system("./#{f[0]}") }
end
