# frozen_string_literal: true

#=================
# IMPORTS
#=================
# Imported gems
require 'tty-prompt'

# Imported files
require_relative 'Connect4/version'

# Main module
module Connect4
  #=================
  # ERORR HANDLING
  #=================
  class Error < StandardError
    def initialize(msg = "\nAn uncaught error occured. Please try again.")
      super(msg)
    end
  end

  class Game
    #=================
    # INITIALIZATION
    #=================
    def initialize
      @game_board = Array.new(6) { Array.new(7, ' ') }
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
      puts '  1   2   3   4   5   6   7'
      puts '-' * 29
      @game_board.each do |row|
        row.each do |el|
          print "| #{el} "
        end
        puts '|'
        puts '-' * 29
      end
      puts '/\\' + ' ' * 25 + '/\\'
    end
    
    # Update which columns can be selected for this turn
    def update_valid_columns
      @valid_columns = []
      @game_board[0].each_with_index do |el, index|
        el == ' ' ? @valid_columns.push(index + 1) : nil
      end
    end

    # Checks if every element in the array is not blank
    def draw?
      if @game_board.all? { |row| row.all? { |el| el != ' '} }
        render_board
        
        puts
        @prompt.keypress(
          "The board has been filled and it's a draw!", keys: [:return]
        )
        exit
      end
    end

    # Checks if there's a winning combination and handles victory if acheived
    def update_win_state
      @winner = false

      # Helper method checks rows and columns for contiguous series of player tokens
      def row_column_winner?(arr)
        arr.each do |row|
          if row.each_cons(4).include? Array.new(4, @player_tokens[@current_player])
            @winner = true
            break
          end
        end
      end

      row_column_winner?(@game_board)
      row_column_winner?(@game_board.transpose)

      # Helper method gets diagonals
      def diagonal_winner?(arr)
        padding = arr.size - 1
        padded_matrix = []

        arr.each do |row|
          inverse_padding = arr.size - padding
          padded_matrix << ([nil] * inverse_padding) + row + ([nil] * padding)
          padding -= 1
        end

        row_column_winner?(padded_matrix.transpose.map(&:compact))
      end

      diagonal_winner?(@game_board)
      diagonal_winner?(@game_board.transpose.map(&:reverse))

      # Renders the winning board and winner message
      if @winner
        render_board

        puts
        @prompt.keypress(
          "Player #{@current_player} with the #{@player_tokens[@current_player]} token has won! Press Enter to exit.", keys: [:return]
        )
        exit
      end
    end

    # Computer randomly picks from available options
    def computer_turn
      update_valid_columns
      @computer_turn = @valid_columns.sample
      update_game_board(@computer_turn)
    end

    # Update game board state
    def update_game_board(column)
      # Goes through each row from bottom to top until it finds an empty slot to populate
      (0..5).reverse_each do |index|
        if @game_board[index][column.to_i - 1] == ' '
          @game_board[index][column.to_i - 1] = @player_tokens[@current_player]
          break
        end
      end

      # Check for a draw
      draw?

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
      puts "Computer placed a token in column #{@computer_turn}" if @computer_turn
      puts "Your move, Player #{@current_player}! Place an #{@player_tokens[@current_player]} token."
      puts "Valid columns are #{@valid_columns.to_s.gsub(/[\[\]]/, '')}."

      update_game_board(
        @prompt.ask('What is your move?') do |q|
          q.validate(/^[#{Regexp.quote(@valid_columns.to_s.gsub(/[, \[\]]/, ''))}]$/)
          q.messages[:valid?] = 'Invalid column selected: %{value}. Try again.'
          q.modify :strip, :collapse
        end
      )
    end

    # Game setup
    def set_game_options
      system('clear') || system('cls')
      puts "Game Setup"
      puts

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

      puts
      @prompt.keypress("Press Enter to continue...", keys: [:return])

      game_menu
    end

    # Menu when starting the program
    def main_menu
      system('clear') || system('cls')
      puts 'Connect Four! by Alex Pike'
      puts

      @prompt.select('Main Menu:') do |menu|
        menu.choice 'Start', -> { set_game_options }
        menu.choice 'Quit', -> { exit }
      end
    end
  end
end

Connect4::Game.new.main_menu
