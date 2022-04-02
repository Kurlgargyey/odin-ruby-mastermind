# frozen_string_literal: true

# this class will mediate between the two players
class Game
  def initialize

  end
end

# shared behavior/states for player class
class Player
  attr_reader :points, :guess, :code_length, :legal_colors

  def initialize(points = 0)
    @points = points
    @code_length = 4
    @legal_colors = %w[R O Y G B I V X]
  end

  protected

  attr_reader :code
end

# handling of user input for user-controlled player
class User < Player
  attr_reader :name

  def initialize(name, points = 0)
    super(points)
    @name = name
  end

  def guess!
    puts "It's your turn to make a guess, #{name}!"
    self.guess = gets.chomp.upcase
    guess
  end

  def code!
    puts "Please decide what the code should be, #{name}!"
    self.code = gets.chomp.upcase
    code
  end

  private

  def validate(string)
    string.length == code_length && string.chars.all? { |char| legal_colors.any?(char) }
  end

  def repeat_prompt(type)
    puts "Your #{type} was invalid, please enter a different one."
    puts "Make sure your #{type} is #{code_length} places long and only contains legal colors."
    puts 'The legal colors are (R)ed, (O)range, (Y)ellow, (G)reen, (B)lue, (I)ndigo, (V)iolet and X for a blank spot.'
  end

  def guess=(string)
    if validate(string)
      @guess = string
    else
      repeat_prompt('guess')
      guess!
    end
  end

  def code=(string)
    if validate(string)
      @code = string
    else
      repeat_prompt('code')
      code!
    end
  end
end

# computer-controlled player behavior
class Computer < Player
  def guess!
    puts 'The computer is making a guess...'
    self.guess = +''
    4.times { @guess += legal_colors.sample }
    guess
  end

  protected

  def code!
    puts 'The computer is setting a code...'
    self.code = +''
    4.times { @code += legal_colors.sample }
    code
  end
end
