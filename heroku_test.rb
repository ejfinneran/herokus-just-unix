require 'csv'
require 'benchmark'
require 'sinatra/base'

class HerokuTest < Sinatra::Base

  def mem_usage
    `ps -o rss=  #{Process.pid}`.to_i
  end

  get("/unix_sort") do
    mem_start = mem_usage
    time = Benchmark.measure { puts `sort -g --field-separator=',' --key=2 fielding.csv > sorted.csv` }.real
    f = File.open("sorted.csv")
    mem_end = mem_usage
    output = []
    output << "Finished in #{time.to_s}"
    output << "Memory growth: #{mem_end - mem_start}"
    output << "First sorted line:"
    output << f.readline
    output.join("\n")
  end

  get("/ruby_sort") do
    mem_start = mem_usage
    time = Benchmark.measure do
      @file = CSV.parse(File.read("fielding.csv"))
      @file.sort_by! {|b| b.values_at(1,0) }
    end.real
    mem_end = mem_usage
    output = []
    output << "Finished in #{time.to_s}"
    output << "Memory growth: #{mem_end - mem_start}"
    output << "First sorted line:"
    output << @file.first.join(",") + "\n"
    output.join("\n")
  end
end
