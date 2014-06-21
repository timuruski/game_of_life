#! /usr/bin/env ruby

require 'io/console'

module Conway
  FRAMERATE = 10

  def self.run(args)
    IO.console.echo = false

    win_rows, win_cols = IO.console.winsize
    world = World.new(win_rows, win_cols, DATA.read)
    # world.clear

    at_exit do
      world.clear
    end

    [:INT, :QUIT].each do |signal|
      trap(signal, 'EXIT')
    end

    loop do
      world.draw
      sleep 1.0 / FRAMERATE
      world.tick
    end
  end

  class World
    SEED = 123 # 42
    PROB = 0.10

    LIVING_CELL = true
    DEAD_CELL = false

    CLEAR = "\e[0m\e[2J"
    DEAD = "\e[0m"
    ALIVE = "\e[0;41m"

    def initialize(rows, cols, initial_state = nil)
      @rows, @cols = rows, cols
      @size = rows * cols
      # @cells = setup_cells_from_string(initial_state)
      @cells = setup_cells_from_seed(SEED)
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

      IO.console.print cells.chomp
      IO.console.flush
    end

    def draw_cell(cell)
      "#{cell == LIVING_CELL ? ALIVE : DEAD} "
    end

    def clear
      IO.console.print CLEAR
    end

    protected

    def setup_cells_from_string(string)
      cells = []
      seed = string.split("\n")
      @rows.times do |r|
        line = seed[r] || []
        @cols.times do |c|
          s = (/\w/ === line[c]) ? LIVING_CELL : DEAD_CELL
          cells << s
        end
      end

      cells
    end

    def setup_cells_from_seed(seed)
      sr = Random.srand(seed)
      Array.new(@rows * @cols) { (rand < PROB) ? LIVING_CELL : DEAD_CELL }
    ensure
      Random.srand(sr)
    end

    # Returns: false for dead, alive for true
    def dead_or_alive?(row, col)
      cell = cell(row, col)
      living_neighbors = living_neighbors(row, col)

      if living_neighbors == 3
        LIVING_CELL
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
      return nil if row < 0 || row > @rows - 1
      return nil if col < 0 || col > @cols - 1

      @cells[@cols * row + col]
    end

    def living?(row, col)
      cell(row, col) == LIVING_CELL
    end

  end
end

Conway.run(ARGV) if $0 == __FILE__

__END__





                              x
                               x
                             xxx
