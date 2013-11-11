class Tweet
  attr_accessor :id, :body
  def initialize
    @id = rand(10000000000000)
    @body = Forgery(:lorem_ipsum).words(10, random: true)
  end
end

def random_word
  Forgery(:lorem_ipsum).words(1, random: true)
end
