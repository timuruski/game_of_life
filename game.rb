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

  class Border
    def initialize(glyphs)
      @hborder, @vborder,
      @tlcorner, @trcorner,
      @blcorner, @brcorner = glyphs.split('')
    end

    attr_reader :hborder, :vborder,
                :tlcorner, :trcorner,
                :blcorner, :brcorner
  end

  class Box
    def initialize(x, y, width, height)
      @x, @y = x, y
      @width, @height = width, height
      @border = Border.new('━┃┏┓┗┛')
      # @border = Border.new('═║╔╗╚╝')
    end

    attr_reader :width, :height, :x, :y

    def to_s
      ''.tap do |s|
        height.times do |y|
          width.times do |x|
            if y == 0 && x == 0
              c = @border.tlcorner
            elsif y == 0 && x == width - 1
              c = @border.trcorner
            elsif y == height - 1 && x == 0
              c = @border.blcorner
            elsif y == height - 1 && x == width - 1
              c = @border.brcorner
            elsif y == 0 || y == height - 1
              c = @border.hborder
            elsif x == 0 || x == width - 1
              c = @border.vborder
            else
              c = " "
            end

            s << c
          end
          s << "\n"
        end
      end
    end

    def draw(out)
      out.print "\e[0m"
      to_s.each_line.with_index do |line, i|
        out.print "\e[#{y + i};#{x}f" + line
      end
    end
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

      win_height, win_width = IO.console.winsize
      box_width = win_width / 2
      box_height = win_height / 2
      box_x = (win_width / 2) - (box_width / 2)
      box_y = (win_height / 2) - (box_height / 2)
      @box = Box.new(box_x, box_y, box_width, box_height)


      clear
      while @running
        reset_cursor
        draw
        $stdout.flush
        sleep 0.1
      end

      IO.console.echo = false
      sleep 0.2
      clear
    end

    def draw
      @box.draw(IO.console)
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
