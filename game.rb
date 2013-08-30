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
      @h,@v,@tl,@tr,@bl,@br = glyphs.split('')
    end

    attr_reader :h,:v,:tl,:tr,:bl,:br
  end

  class World
    FRAME_RATE = 12.0

    def initialize(config)
      @config = config
      @running = false
      @rows = config.size
      @cols = config.size * 2
      @framerate = config.framerate
    end

    attr_reader :config, :rows, :cols

    def before_start
      # randomize cells
    end

    def start
      @running = true
      IO.console.echo = false
      handle_signals

      before_start

      clear
      while @running
        reset_cursor
        draw
        $stdout.flush
        sleep 1.0 / @framerate
      end

      IO.console.echo = false
      clear
    end

    def draw
      draw_border
      draw_grid
      # @box.draw(IO.console)
    end

    def draw_border
      win_height, win_width = IO.console.winsize

      t = (win_height / 2) - (rows / 2)
      r = (win_width / 2) + (cols / 2)
      b = (win_height / 2) + (rows / 2)
      l = (win_width / 2) - (cols / 2)

      @b = Border.new('━┃┏┓┗┛')
      rows.times { |y|
        print "#{pos(t + y,l,@b.v)}#{pos(t + y,r + 1,@b.v)}" }
      print pos(t,l,"#{@b.tl}#{@b.h * cols}#{@b.tr}")
      print pos(b,l,"#{@b.bl}#{@b.h * cols}#{@b.br}")
    end

    def draw_grid
    end

    def print(str)
      IO.console.print(str)
    end

    def pos(y,x,char = nil)
      "\e[#{y};#{x}f#{char}"
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
      config.size = 16
      config.framerate = 12

      parser = OptionParser.new do |opts|
        opts.on '-s', '--size SIZE', "Size of the world" do |value|
          config.size = value.to_i
        end

        opts.on '--framerate RATE', "Framerate to render at" do |value|
          config.framerate = value.to_i
        end
      end.parse!(args)

      config
    end
  end

end

Game.run(ARGV) if $0 == __FILE__
