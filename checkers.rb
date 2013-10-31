# -*- coding: utf-8 -*-
require 'colorize'

class Game
  attr_accessor :board
  def initialize
    @board = Board.new
    @players = [:white, :black]
    @current_player = :white
    @board.render
  end

  def play_game
    until game_over?
      play_turn(@current_player)
      @current_player = (@current_player == :white) ? :black : :white
    end
  end

  def play_turn(color)
    @board.render
  end

  def game_over?()
    # @board.
  end

end

class Board
  attr_accessor :rows

  def initialize(start_board = true)
    @rows = Array.new(8) { Array.new(8) }
    starting_positions if start_board
  end

  def starting_positions
    self.rows.each_with_index do |row,r_num|
      row.each_with_index do |sqr, c_num|
        if (r_num + c_num).odd?
          case r_num
          when 0..2
            @rows[r_num][c_num] = Piece.new(:black, [r_num,c_num], :pawn, self)
          when 5..7
            @rows[r_num][c_num] = Piece.new(:white, [r_num,c_num], :pawn, self)
          end
        end
      end
    end
  end

  def render
    header = "   0 1 2 3 4 5 6 7"
    puts header + "\n"
    self.rows.each_with_index do |row,r_num|
      print r_num.to_s + " "
      row.each_with_index do |sqr,c_num|
        # p "sqr: #{sqr}"
        if sqr.nil?
          char = "  "
        else
          char = sqr.render + " "
        end
        back_color = (r_num + c_num).odd? ? :black : :red
        print char.colorize(background: back_color)
      end
      puts
    end
    print header
    puts
  end

  def [](pos)
    raise "invalid pos" unless valid_pos?(pos)

    i, j = pos
    @rows[i][j]
  end

  def []=(pos, piece)
    raise "invalid pos" unless valid_pos?(pos)
    i, j = pos
    @rows[i][j] = piece
  end


  def perform_slide(start,finish)
    raise "start position is empty" if self[start].nil?

    piece = self[start]
    if !piece.slide_moves.include?(finish)
      raise "piece doesn't move like that"
    end

    perform_slide!(start, finish)
  end

  def perform_slide!(start,finish)
    piece = self[start]
    self[finish] = piece
    self[start] = nil
    piece.pos = finish
    nil
  end



  def perform_jump(start,finish)

  end


  def perform_jump!(start,finish)
    jumpover_pos = []

    jumpover_pos[0] = (start[0] - ((start[0]-finish[0] ) /2))
    jumpover_pos[1] = (start[1] - ((start[1]-finish[1] ) /2))

    self[jumpover_pos] = nil
    piece = self[start]
    self[finish], self[start] = piece, nil
    piece.pos = finish

    nil
  end


  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7)} && (pos[0]+pos[1]).odd?
  end

  def occupied?(position)
    pieces.any? {|piece| piece.pos == position}
  end

  def pieces
    @rows.flatten.compact
  end

end

class Piece
  attr_accessor :color, :pos, :type, :symbol, :board

  def initialize(color = :white, pos, type, board)
    @color = color
    @pos = pos
    @type = type
    @board = board
  end

  def symbols
    { pawn: { white: '⚪', black: '⚫' },
      king: { white: '♕', black: '♛' } }
  end

  def promote
    self.type = :king
  end

  def render
    symbols[type][color]
  end

  def diagonal?(pos)
    (pos[0] + pos[1]).odd?
  end

  def inbounds?(pos)
    (0..7).include?(pos[0]) && (0..7).include?(pos[1])
  end

  def slide_move_dirs
    black_deltas = [[ 1,-1], [ 1, 1]]
    white_deltas = [[-1,-1], [-1, 1]]

    case self.type
    when :king
      deltas = black_deltas + white_deltas
    else
      case self.color
      when :black
        deltas = black_deltas
      else
        deltas = white_deltas
      end
    end

    deltas
  end

  def jump_move_dirs
    slide_move_dirs.map {|pos| pos.map {|el| el*2}}
  end

  def slide_moves
    moves = []
    current_pos = self.pos
    slide_move_dirs.each do |delta|
      move = [current_pos[0] + delta[0], current_pos[1] + delta[1]]
      if @board.valid_pos?(move) && !@board.occupied?(move)
        moves << move
      end
    end
    moves
  end

  def jump_moves
    moves = []
    current = self.pos
    jump_move_dirs.each do |delta|
      j_move = [current[0] + delta[0], current[1] + delta[1]]
      s_move = [current[0] + (delta[0]/2), current[1] + (delta[1]/2)]
      if @board.valid_pos?(j_move) && !@board.occupied?(j_move)
        if @board.occupied?(s_move)
          moves << j_move
        end
      end
    end
    moves
  end

  def moves
    slide_moves + jump_moves
  end

end