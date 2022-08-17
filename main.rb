require 'csv'
# rvm use 3.0.0
# ruby main.rb

puts "+++> #{File.dirname(__FILE__)}/players.csv"
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


puts "\n\n"
