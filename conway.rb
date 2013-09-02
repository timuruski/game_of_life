#! /usr/bin/env ruby

require 'io/console'

module Conway
  FRAMERATE = 0.20
  SEED = 1

  def self.run(args)
    Random.srand(SEED)
    IO.console.echo = false

    [:INT, :QUIT].each { |s| trap(s) {
      IO.console.print World::CLEAR
      exit
    } }

    world = World.new
    loop do
      world.draw
      world.tick
      sleep FRAMERATE
    end
  end

  class World
    PROB = 0.01
    DEFAULT_ROWS = 24
    DEFAULT_COLS = 48

    CLEAR = "\e[2J"
    RESET = "\e[H"
    DEAD = "\e[0m "
    ALIVE = "\e[0;41m "

    def initialize(rows = nil, cols = nil)
      win_rows, win_cols = IO.console.winsize
      @rows = rows || win_rows
      @cols = cols || win_cols

      @cells = Array.new(@rows) do |i|
        Array.new(@cols) do |i|
          rand > PROB ? DEAD : ALIVE
        end
      end
    end

    def tick
      new_cells = Array.new(@rows) do |r|
        Array.new(@cols) do |c|
          cell = @cells[r][c]
          should_die?(cell, r, c) ? DEAD : ALIVE
        end
      end

      @cells = new_cells
    end

    def draw
      IO.console.print CLEAR
      IO.console.puts @cells.map { |row| row.join('') }
    end

    def draw_slow
      # IO.console.print CLEAR
      IO.console.print RESET
      @cells.each_with_index do |cols, r|
        cols.each_with_index do |cell, c|
          draw_cell(r, c, cell)
        end
      end

      IO.console.flush
    end

    protected

    def should_die?(cell, row, col)
      neighbors = neighbors_of(row, col)
      alive = neighbors.select { |c| c == ALIVE }.length
      # dead = neighbors.select { |c| c == DEAD }.length

      alive < 2 || alive > 3
    end

    def neighbors_of(row, col)
      [
        cell(row - 1, col - 1),
        cell(row - 1, col),
        cell(row - 1, col + 1),
        cell(row, col - 1),
        cell(row, col + 1),
        cell(row + 1, col - 1),
        cell(row + 1, col),
        cell(row + 1, col + 1)
      ].compact
    end

    def cell(row, col)
      return nil if row < 0 || row > @rows - 1
      return nil if col < 0 || col > @cols - 1

      @cells[row][col]
    end

    def draw_cell(row, col, cell)
      # win_rows, win_cols = IO.console.winsize
      # row = (win_rows / 2) - (@rows / 2) + row
      # col = (win_cols / 2) - (@cols / 2) + col

      IO.console.print "\e[#{row};#{col}H#{cell}"
    end

  end
end

Conway.run(ARGV) if $0 == __FILE__
