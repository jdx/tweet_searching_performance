class Tweet
  attr_accessor :id, :body
  def initialize
    @id = rand(10000000000000)
    @body = Forgery(:lorem_ipsum).words(10, random: true)
  end
end
