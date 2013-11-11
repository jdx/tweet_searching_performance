#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'benchmark'
require_relative 'tweet'

RECORD_COUNT = 15000000

$pg = PG.connect(dbname: 'tweet_perf')

def create_table
  $pg.exec <<-eom
  CREATE TABLE IF NOT EXISTS tweets(
    id SERIAL,
    tweet_id bigint,
    body varchar
  );
  eom
end

def tweet_count
  res = $pg.exec "SELECT count(*) FROM tweets"
  res.first["count"].to_i
end

def populate_table(num, chunk: 1000)
  $pg.exec <<-eom
  PREPARE bulk_load (bigint, varchar) AS
    INSERT INTO tweets (tweet_id, body) VALUES($1, $2);
  eom
  $pb = ProgressBar.create title: 'Loading tweets', starting_at: tweet_count, total: RECORD_COUNT, format: '%E %B %p%% %t %c'
  groups = num / chunk
  groups.times do
    $pg.exec "BEGIN"
    chunk.times do
      tweet = Tweet.new
      $pg.exec_prepared "bulk_load", [tweet.id, tweet.body]
      $pb.increment
    end
    $pg.exec "COMMIT"
  end
end

def search(method, q)
  case method
  when :like
    res = $pg.exec_params "SELECT count(*) FROM tweets WHERE body ILIKE $1 LIMIT 100", ["%#{q}%"]
  when :full_text
    # Should have index:
    # CREATE INDEX ft_tweet_body ON tweets USING gin(to_tsvector('english', body));
    query = <<-eom
      SELECT count(*) FROM tweets WHERE to_tsvector('english', body) @@ to_tsquery('english', $1) LIMIT 100
    eom
    res = $pg.exec_params query, [q]
  end
  res.to_a
end

create_table
num_to_create = RECORD_COUNT - tweet_count
populate_table(num_to_create) if num_to_create > 0

n = 1
puts "Running benchmarks by searching #{n} times..."
Benchmark.bm do |x|
  x.report("full text query") { n.times do search(:full_text, random_word) end }
  x.report("ILIKE query") { n.times do search(:like, random_word) end }
end
