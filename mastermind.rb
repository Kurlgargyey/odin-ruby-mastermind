# frozen_string_literal: true

# this class will mediate between the two players
class Game
  @@scores = Hash.new(0)

  def initialize
    @user = User.new
    @computer = Computer.new
    @max_guesses = 10
    @guesses = 0
    puts 'Do you want to be the codemaker? Y/N'
    decide_role
  end

  def run_game
    @codemaker.code!
    game_loop
    puts "The game ended at round #{@guesses}!"
    puts scores
    reinitialize
  end

  private

  def yes_no_prompt
    ans = gets.chomp.upcase until %w[Y N].include?(ans)
    ans
  end

  def decide_role
    ans = yes_no_prompt
    if ans == 'Y'
      puts 'Great!'
      @codemaker = @user
      @codebreaker = @computer
    else
      puts 'Alright, the computer will set a code.'
      @codebreaker = @user
      @codemaker = @computer
    end
  end

  def process_round
    guess = @codebreaker.guess!
    hints = @codemaker.process_guess(guess)
    puts "The guess got #{hints[0]} places right. #{hints[1]} colors were correct, but in the wrong place."
    return true if hints[0] == @codemaker.code_length

    @guesses += 1
    @codebreaker.optimize_guess(guess, @codemaker) if @codebreaker.name == 'Computer'
    false
  end

  def game_over(state)
    case state
    when 1
      puts 'The code was broken!'
      @@scores[@codemaker.name] += @guesses
    when 0
      puts 'The code held up!'
      @@scores[@codemaker.name] += (@guesses + 1)
    end
  end

  def scores
    codebreaker_score = "#{@@scores[@codebreaker.name]} for #{@codebreaker.name}"
    codemaker_score = "#{@@scores[@codemaker.name]} for #{@codemaker.name}"
    "The scores are #{codemaker_score} and #{codebreaker_score}."
  end

  def game_loop
    loop do
      if process_round
        game_over(1)
        break
      elsif @guesses == @max_guesses
        game_over(0)
        break
      end
    end
  end

  def reinitialize
    puts 'Would you like to play again? Y/N'
    ans = yes_no_prompt
    if ans == 'Y'
      puts 'Reinitializing game...'
      @guesses = 0
      @codemaker, @codebreaker = @codebreaker, @codemaker
      @codebreaker.reset_perms if @codebreaker.name == 'Computer'
      run_game
    else
      puts 'OK, have a nice day!'
      sleep 2
    end
  end
end

# shared behavior/states for player class
class Player
  attr_reader :guess, :name

  @@code_length = 3
  @@legal_colors = %w[R O Y G B I V X]

  def code_length
    @@code_length
  end

  def legal_colors
    @@legal_colors
  end

  def initialize; end

  def process_guess(guess)
    code = @code.clone
    hits = code.intersection(guess).length
    hints = check_partials(code, guess)
    [hits, hints]
  end

  protected

  attr_reader :code

  private

  def check_partials(code, guess)
    hints = 0
    code -= guess
    guess -= @code
    guess.each do |guess_idx|
      code.each do |code_idx|
        if guess_idx[0] == code_idx[0]
          hints += 1
          code.delete(code_idx)
        end
      end
    end
    hints
  end

  def char_idx_array(string)
    array = []
    string.each_char.with_index do |char, idx|
      array.push([char, idx])
    end
    array
  end
end

# handling of user input for user-controlled player
class User < Player
  def initialize
    super
    puts 'What is your name?'
    @name = gets.chomp
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
    string.length == code_length && string.chars.all? { |char| legal_colors.include?(char) }
  end

  def repeat_prompt(type)
    puts "Your #{type} was invalid, please enter a different one."
    puts "Make sure your #{type} is #{code_length} places long and only contains legal colors."
    puts 'The legal colors are (R)ed, (O)range, (Y)ellow, (G)reen, (B)lue, (I)ndigo, (V)iolet and X for a blank spot.'
  end

  def guess=(string)
    if validate(string)
      @guess = char_idx_array(string)
    else
      repeat_prompt('guess')
      guess!
    end
  end

  def code=(string)
    if validate(string)
      @code = char_idx_array(string)
    else
      repeat_prompt('code')
      code!
    end
  end
end

# computer-controlled player behavior
class Computer < Player
  def initialize
    super
    @name = 'Computer'
    @perms = []
    legal_colors.permutation(code_length) { |perm| @perms.push(perm) }
  end

  def reset_perms
    @perms = []
    legal_colors.permutation(code_length) { |perm| @perms.push(perm) }
  end

  def guess!
    puts 'The computer is making a guess...'
    # guess = +''
    # code_length.times { guess += legal_colors.sample }
    guess_string = @perms.sample.sum('')
    sleep 2
    puts "The computer guessed #{guess_string}."
    @guess = char_idx_array(guess_string)
  end

  def code!
    puts 'The computer is setting a code...'
    code_string = +''
    code_length.times { code_string += legal_colors.sample }
    @code = char_idx_array(code_string)
  end

  def optimize_guess(guess, player)
    @perms.reject! do |perm|
      player.process_guess(guess) == player.process_guess(char_idx_array(perm.sum('')))
    end
  end
end

game = Game.new
game.run_game
