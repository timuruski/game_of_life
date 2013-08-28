#! /usr/bin/env ruby

# The Game of Life
# ================


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

    def start
      @running = true
      handle_signals

      clear
      while @running
        reset_cursor
        draw
        $stdout.flush
        sleep 0.3
      end

      sleep 0.2
      clear
    end

    def draw
      @dots ||= ['   ', '.  ', '.. ', '...'].cycle
      line "Draw#{@dots.next}\n"
      line "Draw#{@dots.next}\n"
      line "Draw#{@dots.next}\n"
    end

    def line(str = '')
      puts "\e[0K" + str
    end

    def reset_cursor
      print "\e[H"
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
      config.size = 16
    end
  end

end

Game.run(ARGV) if $0 == __FILE__
