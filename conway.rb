#! /usr/bin/env ruby

require 'io/console'

module Conway
  FRAMERATE = 0.2

  def self.run(args)
    [:INT, :QUIT].each { |s| trap(s) { exit } }

    world = World.new
    loop do
      world.draw
      world.tick
      sleep FRAMERATE
    end

  end

  class World
    DEFAULT_ROWS = 24
    DEFAULT_COLS = 48

    CLEAR = "\e[2J"
    DEAD = "\e[0m "
    ALIVE = "\e[7m "

    def initialize(rows = nil, cols = nil)
      @rows = rows || DEFAULT_ROWS
      @cols = cols || DEFAULT_COLS

      @cells = Array.new(@rows) do |i|
        Array.new(@cols) do |i|
          rand > 0.8 ? ALIVE : DEAD
        end
      end
    end

    def tick
      @cells = Array.new(@rows) do |i|
        Array.new(@cols) do |i|
          rand > 0.8 ? ALIVE : DEAD
        end
      end
    end

    def draw
      print CLEAR
      @cells.each_with_index do |cols, r|
        cols.each_with_index do |cell, c|
          draw_cell(r, c, cell)
        end
      end
    end

    def draw_cell(row, col, cell)
      win_rows, win_cols = IO.console.winsize
      row = (win_rows / 2) - (@rows / 2) + row
      col = (win_cols / 2) - (@cols / 2) + col

      IO.console.print "\e[#{row};#{col}H#{cell}"
    end
  end
end

Conway.run(ARGV) if $0 == __FILE__
