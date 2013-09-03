#! /usr/bin/env ruby

require 'io/console'

module Conway
  FRAMERATE = 0.01
  TEST_STATE = <<-WORLD

           x
            x
          xxx


                  x
                 x
                 xxx
  WORLD

  def self.run(args)
    IO.console.echo = false

    win_rows, win_cols = IO.console.winsize
    world = World.new(win_rows, win_cols, TEST_STATE)
    world.clear

    [:INT, :QUIT].each { |s| trap(s) {
      world.clear
      exit
    } }

    loop do
      world.draw
      sleep FRAMERATE
      world.tick
    end
  end

  class World
    SEED = 42
    PROB = 0.01

    CLEAR = "\e[0m\e[2J"
    DEAD = "\e[0m"
    ALIVE = "\e[0;41m"

    def initialize(rows, cols, initial_state = nil)
      @rows, @cols = rows, cols
      @cells = setup_cells_from_string(initial_state)
      # @cells = setup_cells_from_seed(SEED)
    end

    def tick
      new_cells = Array.new(@rows) do |r|
        Array.new(@cols) do |c|
          dead_or_alive?(r, c)
        end
      end

      @cells = new_cells
    end

    def draw
      cells = @cells.map { |row|
        row.map { |c| draw_cell(c) }.join('') }.join("\n")
      IO.console.print cells
      IO.console.flush
    end

    def clear
      IO.console.print CLEAR
    end

    protected

    def setup_cells_from_string(string)
      seed = string.split("\n")
      Array.new(@rows) do |r|
        line = seed[r] || []
        Array.new(@cols) do |c|
          s = !!(/\w/ === line[c])
          # puts "#{r}/#{c}/#{line[c]}/#{s}"
          # sleep 0.5
        end
      end
    end

    def setup_cells_from_seed(seed)
      r = Random.srand(SEED)

      Array.new(@rows) do
        Array.new(@cols) do
          rand < PROB
        end
      end
    ensure
      Random.srand(r)
    end

    def draw_cell(cell)
      "#{cell ? ALIVE : DEAD} "
    end

    # Returns: false for dead, alive for true
    def dead_or_alive?(row, col)
      cell = @cells[row][col]
      living_neighbors = neighbors_of(row, col)
      living_neighbors = living_neighbors.select { |n| n == true }.length

      if living_neighbors == 3
        true
      elsif living_neighbors == 2
        cell
      else
        false
      end
    end

    def should_die?(cell, row, col)
      neighbors = neighbors_of(row, col)
      alive = neighbors.select { |c| c == ALIVE }.length
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

  end
end

Conway.run(ARGV) if $0 == __FILE__
