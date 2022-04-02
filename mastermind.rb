class Game
  def initialize

  end
end

class Player
  def initialize (name)
    @name = name
  end
end

class Guesser < Player
  def initialize (name, code)
    super(name)
    @code = code
  end

  private 

  attr_reader :code
end

class Creator < Player

end