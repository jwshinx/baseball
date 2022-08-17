require 'csv'
require_relative './quickselect'
require_relative './binarysearch'
# rvm use 3.0.0
# ruby main.rb

def adjust_player_keys(key)
  if key == 'Height(inches)'
    'height'
  elsif key == 'Weight(lbs)'
    'weight'
  elsif key == 'Team'
    'abb'
  else
    key
  end
end

def import_player_data
  players_file = "#{File.dirname(__FILE__)}/players.csv"
  data = {}
  CSV.foreach(players_file, strip: true, headers: true) do |row|
    sanitized_row = row.to_h.inject({}) do |memo, (k, v)|
      key = adjust_player_keys(k)
      memo[key.downcase.to_sym] = v
      memo
    end
    data[sanitized_row[:name]] = sanitized_row
  end
  data
end

def import_team_data
  teams_file = "#{File.dirname(__FILE__)}/teams.csv"
  data = {}
  CSV.foreach(teams_file, strip: true, headers: true, :converters => lambda {|f| f.strip}) do |row|
    sanitized_row = row.to_h.inject({}) do |memo, (k, v)|
      key = k == 'Payroll (millions)' ? 'payroll' : k
      memo[key.downcase.to_sym] = v
      memo
    end
    data[sanitized_row[:abb]] = sanitized_row
  end
  data
end

def add_players_to_team_data(team_data, player_data)
  player_data.each do |k, player|
    abb = player[:abb]
    team_data[abb][:players] ||= []
    team_data[abb][:players] << player[:name]
  end
  team_data
end

def add_cost_to_team_data(data)
  data.each do |k, obj|
    avg_cost_per_win = (obj[:payroll].to_f / obj[:wins].to_f).round(2)
    obj[:cost] = avg_cost_per_win.to_s
  end
end

team_data = import_team_data
player_data = import_player_data
team_data2 = add_players_to_team_data(team_data, player_data)
team_data3 = add_cost_to_team_data(team_data2)
team_data4 = team_data3.sort_by{|team| team[1][:team] }
team_data4.each do |k, obj|
  puts "#{obj[:team]}\n=======================\n   payroll: $#{obj[:payroll]}M\n   wins: #{obj[:wins]}\n   cost/win: $#{obj[:cost]}M\n#{obj[:players].join(', ')}\n\n"
end
puts "\n"

cost_hash = team_data4.inject({}) do |acc, (k, obj)|
  acc[obj[:cost]] = obj[:team]
  acc
end
costs = cost_hash.keys.map{|item| item.to_f}

# silly demonstration using quickselect.
puts "\nPER WIN TOP SPENDERS"
result = findKthLargest(costs, 1)
puts "#1: $#{result}M - #{cost_hash[result.to_s]}"
result = findKthLargest(costs, 2)
puts "#2: $#{result}M - #{cost_hash[result.to_s]}"
result = findKthLargest(costs, 3)
puts "#3: $#{result}M - #{cost_hash[result.to_s]}"

puts "\nPER WIN BOTTOM SPENDERS"
result = findKthLargest(costs, 26)
puts "#26: $#{result}M - #{cost_hash[result.to_s]}"
result = findKthLargest(costs, 27)
puts "#27: $#{result}M - #{cost_hash[result.to_s]}"
result = findKthLargest(costs, 28)
puts "#28: $#{result}M - #{cost_hash[result.to_s]}"

# bottom 5 spenders using binary search
k = 5
bottom_k_spenders = k_closest_binary_search(costs, k)

puts "\nPER WIN BOTTOM SPENDERS (BINARY SEARCH)"
bottom_k_spenders.each_with_index do |item, idx|
  puts "##{idx + 1} $#{item}M - #{cost_hash[item.to_s]}"
end

puts "\n\n"
