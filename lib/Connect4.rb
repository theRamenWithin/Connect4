# frozen_string_literal: true

# Imported gems
require 'tty-prompt'
require 'matrix'

# Imported files
require_relative 'Connect4/version'

# Main module
module Connect4
  # Error Handling
  class Error < StandardError
    def initialize(msg = "\nAn uncaught error occured. Please try again.")
      super(msg)
    end
  end

  class InvalidInputError < StandardError
    def initialize(msg = "\nInvalid input. Please select an available numbered location.")
      super(msg)
    end
  end

  # Core game logic
  class Game
    # Create a blank board
    def initialize
      @game_board = Array.new(7) { Array.new(6, ' ') }
      @prompt = TTY::Prompt.new
      @current_player = 1
      @player_tokens = { 1 => 'X', 2 => 'O' }
      @vs = 'computer'
      @difficulty = 'normal'
    end

    #=================
    # CORE GAME LOGIC
    #=================
    # Render the game board
    def render_board
      system('clear') || system('cls')
      puts '  1   2   3   4   5   6'
      puts '-' * 25
      @game_board.each do |row|
        row.each do |el|
          print "| #{el} "
        end
        puts '|'
        puts '-' * 25
      end   
    end

    # Update which columns can be selected for this turn
    def update_valid_columns
      @valid_columns = []
      @game_board[0].each_with_index do |el, index|
        el == ' ' ? @valid_columns.push(index + 1) : nil
      end
    end

    def update_win_state
      winner = false

      # Check rows for winner
      @game_board.each do |row|
        if row.each_cons(4).include? Array.new(4, @player_tokens[@current_player])
          winner = true
          break
        end
      end

      # Check columns for winner
      @game_board.transpose.each do |row|
        if row.each_cons(4).include? Array.new(4, @player_tokens[@current_player])
          winner = true
          break
        end
      end

      # Checks diagonals for a winner
      # padding = @game_board.size - 1
      # padded_matrix = []
      # @game_board.each do |row|
      #     inverse_padding = @game_board.size - padding
      #     padded_matrix << ([nil] * inverse_padding) + row + ([nil] * padding)
      #     padding -= 1    
      # end
      # padded_matrix = padded_matrix.transpose.map(&:compact)
      # padded_matrix.each do |row|
      #   if row.each_cons(4).include? Array.new(4, @player_tokens[@current_player])
      #     winner = true
      #     break
      #   end
      # end
      diagonal_arr = Matrix.rows(@game_board).each(:diagonal).to_a

      puts diagonal_arr.to_s
      @prompt.keypress("Press Enter to exit.", keys: [:return])
      

      # .each do |row|
      #   if row.each_cons(4).include? Array.new(4, @player_tokens[@current_player])
      #     winner = true
      #     break
      #   end
      # end

      
      if winner
        render_board
        @prompt.keypress("Player #{@current_player} with the #{@player_tokens[@current_player]} token has won! Press Enter to exit.", keys: [:return])
        exit
      end
    end

    # Computer randomly picks from available options
    def computer_turn
      update_valid_columns
      update_game_board(@valid_columns.sample)
    end

    # Update game board state
    def update_game_board(column)
      # Goes through each row from bottom to top until it finds an empty slot to populate
      (0..6).reverse_each do |index|
        if @game_board[index][column.to_i - 1] == ' '
          @game_board[index][column.to_i - 1] = @player_tokens[@current_player]
          break
        end
      end

      # Check for win state
      update_win_state

      # Update opponent state
      if @vs == 'computer' && @current_player == 1
        @current_player = 2
        computer_turn
      else
        @current_player = @current_player == 1 ? 2 : 1
        game_menu
      end
    end

    #=================
    # CORE GAME UI
    #=================
    # Main game menu loop
    def game_menu
      render_board
      update_valid_columns

      puts
      puts "Your move, Player #{@current_player}! Place an #{@player_tokens[@current_player]} token."
      puts "Valid columns are #{@valid_columns.to_s.gsub(/[\[\]]/, '')}."

      update_game_board(
        @prompt.ask('What is your move?') do |q|
          q.validate(/#{@valid_columns}/)
          q.messages[:valid?] = 'Invalid column selected: %{value}. Try again.'
        end
      )
    end

    # Game setup
    def set_game_options
      system('clear') || system('cls')

      # Opponent options
      @prompt.select('Pick an opponent:') do |menu|
        menu.choice 'Versus Computer'
        menu.choice '2 Player', -> { @vs = 'player' }
      end

      # Options for picking AI strategy
      if @vs == 'computer'
        @prompt.select('Pick a computer difficulty:') do |menu|
          menu.choice 'Easy', -> { @difficulty = 'easy' }
          menu.choice 'Normal'
          menu.choice 'Hard', -> { @difficulty = 'hard' }
        end
      end

      @prompt.select('Player 1, pick a token:') do |menu|
        menu.choice 'X'
        menu.choice 'O', -> { @player_tokens[1] = 'O'; @player_tokens[2] = 'X' }
      end

      game_menu
    end

    # Menu when starting the program
    def main_menu
      system('clear') || system('cls')
      puts 'Connect Four!'

      @prompt.select('Main Menu:') do |menu|
        menu.choice 'Start', -> { set_game_options }
        menu.choice 'Quit', -> { exit }
      end
    end
  end
end

Connect4::Game.new.main_menu
