#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'benchmark'
require_relative 'tweet'

$es = Elasticsearch::Client.new log: false
index_status = $es.indices.status["indices"]["tweets"]
num_docs = index_status ? index_status["docs"]["num_docs"] : 0
RECORD_COUNT = 500000
CHUNK_SIZE = 100

puts "num docs in elasticsearch: #{num_docs}"

pb = ProgressBar.create title: 'Loading tweets', starting_at: num_docs, total: RECORD_COUNT, format: '%E %B %p%% %t %c'

starting_id = RECORD_COUNT - num_docs
chunks = starting_id/CHUNK_SIZE
chunks.times do |i|
  tweet = Tweet.new
  docs = (1..CHUNK_SIZE).map do |j|
    pb.increment
    {
      index: {
        _index: 'tweets',
        _type: 'tweet',
        _id: rand(RECORD_COUNT*100),
        data: { tweet_id: tweet.id, text: tweet.body }
      }
    }
  end
  $es.bulk body: docs
end

def search(q)
  $es.search q: q
end

n = 1000
puts "Running benchmarks by searching #{n} times..."
Benchmark.bm do |x|
  x.report("elasticsearch") { n.times do search(random_word) end }
end
