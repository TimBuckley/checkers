# -*- coding: utf-8 -*-
require 'colorize'

#Tim Buckley's code

class InvalidMoveError < StandardError
end

class Game  #Tim: Game class not really finished, so go easy on me here.
  attr_accessor :board
  def initialize
    @board = Board.new
    @players = [:white, :black]
    @current_player = :white
  end

  def play_game
    until game_won?(@current_player)
      play_turn(@current_player)
      @current_player = (@current_player == :white) ? :black : :white
    end

    puts "Game Over"
  end

  def play_turn(color)
    @board.render
    puts "#{@current_player.to_s.capitalize} Player, provide a move sequence:"

    finish = gets.chomp.split(',').map {|el| el.to_i}
    perform_move[start, finish]
  end

  def game_won?(color) #Tim: Yeah I didn't really finish this.
    # @board.pieces.each do |piece|
  #     piece
  #   end
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

  def perform_moves!(seq)
    case seq.length
    when 0..1
      raise "Invalid sequence"
    when 2
      begin
        perform_slide(seq[0],seq[1])
      rescue
        perform_jump(seq[0],seq[1])
      end
    else
      i = 0
      while i + 1 < seq.length
        perform_jump(seq[i], seq[i+1])
        i += 1
      end
    end
    nil
  end

  def perform_moves(seq)
    if valid_move_seq(seq)
      perform_moves!(seq)
    else
      raise InvalidMoveError.new("Gotta put the right kind of moves.")
    end
  end

  def perform_slide(start,finish)
    raise "start position is empty" if self[start].nil?

    piece = self[start]
    unless piece.slide_moves.include?(finish)
      raise "piece doesn't move like that"
    end
    perform_slide!(start, finish)
    if finish[0]
  end

  def perform_slide!(start,finish)
    piece = self[start]
    self[finish] = piece
    self[start] = nil
    piece.pos = finish
    piece.promotion
    nil
  end

  def jumpover_pos(start,finish)      #helper method
    jump_pos = []
    jump_pos[0] = (start[0] - ( ( start[0]-finish[0] ) /2) )
    jump_pos[1] = (start[1] - ( ( start[1]-finish[1] ) /2) )
    jump_pos
  end

  def perform_jump(start,finish)
    raise "Start position is empty." if self[start].nil?
    raise "No piece to jump over." if self[jumpover_pos(start,finish)].nil?

    perform_jump!(start,finish)
  end

  def perform_jump!(start,finish)
    jump_pos = jumpover_pos(start,finish)

    self[jump_pos] = nil
    piece = self[start]
    self[finish], self[start] = piece, nil
    piece.pos = finish
    piece.promotion

    nil
  end

  def dup
    duplicate = Board.new

    self.rows.each_with_index do |row,row_num|
      row.each_with_index do |square, col_num|
        if square.nil?
          duplicate[[row_num, col_num]] = nil
        else
          duplicate[[row_num, col_num]] = square.dup(duplicate)
        end
      end
    end

    duplicate
  end

  def valid_move_seq?(seq)
    dup_board = self.board.dup
    begin
      dup_board.perform_moves!(seq)
    rescue
      false
    else
      true
    end
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7)} && (pos[0]+pos[1]).odd?
  end

  def occupied?(position)
    #self[position].nil?
    pieces.any? {|piece| piece.pos == position}
  end

  def pieces
    @rows.flatten.compact
  end

end

class Piece
  attr_accessor :color, :pos, :type, :symbol, :board

  DELTAS = {black: [[ 1,-1], [ 1, 1]],
            white: [[-1,-1], [-1, 1]]}

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

  def promotion
    if self.color == :white && self.pos[0] == 0
      self.type = :king
    elsif self.color == :black && self.pos[0] == 7
      self.type = :king
    end

    nil
  end

  def render
    symbols[type][color]
  end

  def diagonal?(pos)
    (pos[0] + pos[1]).odd?
  end

  def slide_move_dirs
    case self.type
    when :king
      DELTAS[:white] + DELTAS[:black]
    else
      DELTAS[self.color]
    end
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