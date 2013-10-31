# -*- coding: utf-8 -*-
require 'colorize'

class Game

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
            @rows[r_num][c_num] = Piece.new(:black, [r_num,c_num], :pawn)
          when 5..7
            @rows[r_num][c_num] = Piece.new(:white, [r_num,c_num], :pawn)
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
  end

  def [](pos)
    raise "invalid pos" unless valid_pos?(pos)

    i, j = pos
    @rows[i][j]
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

end

class Piece
  attr_accessor :color, :pos, :type, :symbol

  def symbols
    { pawn: { white: '⚪', black: '⚫' },
      king: { white: '♕', black: '♛' } }
  end

  def initialize(color = :white, pos, type)
    @color = color
    @pos = pos
    @type = type
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

  def move_dirs
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

  def slide_moves
    current_pos = self.pos

  end

  def jump_moves

  end

end