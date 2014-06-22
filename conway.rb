#! /usr/bin/env ruby

require 'io/console'

module Conway
  LIVE_CELL = true
  DEAD_CELL = false

  DEFAULT_SEED = 123 # 42
  PROB = 0.10

  TICKRATE = 10

  def self.run(args)
    IO.console.echo = false

    win_rows, win_cols = IO.console.winsize
    initial_state = ARGV.any? ?
      state_from_string(win_rows, win_cols, ARGF.read) :
      state_from_seed(win_rows, win_cols, ENV.fetch('SEED', DEFAULT_SEED))

    world = World.new(win_rows, win_cols, initial_state)

    at_exit do
      world.clear
    end

    [:INT, :QUIT].each do |signal|
      trap(signal, 'EXIT')
    end

    loop do
      world.draw
      sleep 1.0 / TICKRATE
      world.tick
    end
  end

  def self.state_from_string(rows, cols, string)
    cells = []
    seed = string.split("\n")
    rows.times do |r|
      line = seed[r] || []
      cols.times do |c|
        s = (/[xX]/ === line[c]) ? LIVE_CELL : DEAD_CELL
        cells << s
      end
    end

    cells
  end

  def self.state_from_seed(cols, rows, seed)
    gen = Random.new(seed.to_i)
    Array.new(rows * cols) { (gen.rand < PROB) ? LIVE_CELL : DEAD_CELL }
  end

  class World
    LIGHT = "\e[0m"
    DARK  = "\e[7m"

    def initialize(rows, cols, initial_state)
      @rows, @cols = rows, cols
      @size = rows * cols
      @cells = initial_state
    end

    def tick
      new_cells = []

      @rows.times do |r|
        @cols.times do |c|
          s = dead_or_alive?(r, c)
          new_cells << s
        end
      end

      @cells = new_cells
    end

    def draw
      cells = ''
      @rows.times do |r|
        @cols.times do |c|
          cell = cell(r, c)
          cells << draw_cell(cell)
        end
        cells << "\n"
      end

      IO.console.print "\e[0;0H"
      IO.console.print cells.chomp
      IO.console.flush
    end

    def draw_cell(cell)
      cell == LIVE_CELL ?
        "#{DARK} " :
        "#{LIGHT} "
    end

    def clear
      IO.console.print "\e[0;0H\e[K\e[0m"
    end

    protected

    # Returns: false for dead, alive for true
    def dead_or_alive?(row, col)
      cell = cell(row, col)
      living_neighbors = living_neighbors(row, col)

      if living_neighbors == 3
        LIVE_CELL
      elsif living_neighbors == 2
        cell
      else
        DEAD_CELL
      end
    end

    def living_neighbors(row, col)
      score = 0

      score += 1 if living?(row - 1, col - 1)
      score += 1 if living?(row - 1, col)
      score += 1 if living?(row - 1, col + 1)
      score += 1 if living?(row, col - 1)
      score += 1 if living?(row, col + 1)
      score += 1 if living?(row + 1, col - 1)
      score += 1 if living?(row + 1, col)
      score += 1 if living?(row + 1, col + 1)

      score
    end

    def cell(row, col)
      row = row % @rows
      col = col % @cols

      @cells[@cols * row + col]
    end

    def living?(row, col)
      cell(row, col) == LIVE_CELL
    end

  end
end

Conway.run(ARGV) if $0 == __FILE__
