#! /usr/bin/env ruby
# encoding: utf-8

# The Game of Life
# ================


require 'io/console'
require 'optparse'
require 'ostruct'

module Game
  def self.run(args)
    config = Config.parse(args)
    World.new(config).start
  end

  class World
    def initialize(config)
      @config = config
      @running = false
    end

    attr_reader :config

    def start
      @running = true
      IO.console.echo = false
      handle_signals

      clear
      while @running
        reset_cursor
        draw
        $stdout.flush
        sleep 0.3
      end

      IO.console.echo = false
      sleep 0.2
      clear
    end

    HBORDER = "━"
    VBORDER = "┃"
    TLCORNER = "┏"
    TRCORNER = "┓"
    BLCORNER = "┗"
    BRCORNER = "┛"

    def draw
      win_height, win_width = IO.console.winsize
      box_height, box_width = [20, 72]

      box = ''.tap do |s|
        box_height.times do |y|
          box_width.times do |x|
            if y == 0 && x == 0
              c = TLCORNER
            elsif y == 0 && x == box_width - 1
              c = TRCORNER
            elsif y == box_height - 1 && x == 0
              c = BLCORNER
            elsif y == box_height - 1 && x == box_width - 1
              c = BRCORNER
            elsif y == 0 || y == box_height - 1
              c = HBORDER
            elsif x == 0 || x == box_width - 1
              c = VBORDER
            else
              c = " "
            end

            s << c
          end
          s << "\n"
        end
      end

      IO.console.puts box
    end

    def width
      config.size
    end

    def height
      config.size
    end

    def line(str = '')
      puts "\e[0K" + str
    end

    def position_cursor(y,x)
      print "\e[#{y};#{x}"
    end

    def reset_cursor
      print "\e[f"
    end

    def clear
      print "\e[2J"
    end

    def handle_signals
      [:INT, :QUIT].each do |signal|
        trap(signal) {
          puts "\nExiting..."
          @running = false
        }
      end
    end
  end

  module Config
    def self.parse(args)
      config = OpenStruct.new
      config.size = 2
    end
  end

end

Game.run(ARGV) if $0 == __FILE__
