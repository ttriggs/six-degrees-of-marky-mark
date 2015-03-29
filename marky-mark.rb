#!/usr/bin/env ruby
require 'csv'
require 'pry'

if ARGV.length != 1
  puts "usage: #{__FILE__} \"<actor name>\""
  exit(1)
end

# DEFAULTS:
MARKS_ID     = 1841
FAIL_LENGTH  = 8
MAX_SOLVED_PATHS = 3  #show max of 3 equivalent degree paths
target_actor  = ARGV[0]
@solved_nodes = []
cast_csv    = './cast_members.csv'
@actors_csv = './actors.csv'
movies_csv  = './movies.csv'

@cast_data = {}
CSV.foreach(cast_csv) do |actor_id, movie_id|
  @cast_data["#{movie_id}"] = [] unless @cast_data.has_key?("#{movie_id}")
  @cast_data["#{movie_id}"] << actor_id.to_i
end

def csv_lookup(look_index, return_index, match, csv_file)
  answer = ""
  CSV.foreach(csv_file) do |row|
    answer = row[return_index] if row[look_index] == match
  end
  answer
end

def get_movies_starring_actor(actor_id, movies_in_node)
  movies = @cast_data.select {|k,v| k if v.include?(actor_id) }.keys
  movies - movies_in_node  # don't add movies already within search path
end

def get_actors_given_movie(movie_id)
  @cast_data.select {|k,v| k if k == "#{movie_id}" }.values[0]
end

def found_mark?(actor_array)
  actor_array.include?(MARKS_ID)
end

def deep_copy_node(node)
  Marshal.load(Marshal.dump(node))
end


def best_solved_degrees
  return FAIL_LENGTH if @solved_nodes.empty?
  @solved_nodes.map { |sn| sn[:degrees] }.min
end

def get_best_solved_nodes
  shortest_path = best_solved_degrees
  @solved_nodes.select {|node| node if node[:degrees] == shortest_path }
end

def keep_node?(node)
  return false if @solved_nodes.length >= MAX_SOLVED_PATHS
  if node[:degrees] >= FAIL_LENGTH || node[:degrees] >= best_solved_degrees
    return false
  end
  true
end

def get_active_actor(node)
  node[:conn_actors][-1]  # get most recently added actor
end

def get_actor_id_from_name(actor_name)
  actor_id = csv_lookup(1, 0, actor_name, @actors_csv)
  if actor_id.empty?
    puts "Sorry, #{actor_name} not found in our DB!"
    exit 1
  end
  actor_id.to_i
end

# setup initial node:
target_actor_id = get_actor_id_from_name(target_actor)
nodes = [ {conn_actors: [target_actor_id], conn_movies: [], degrees: 0 } ]

#########
# BEGIN #
#########
until nodes.length == 0
  active_node = nodes.shift # rip off first node in list

  next if !keep_node?(active_node)   # check if degrees/path too long

  active_actor = get_active_actor(active_node)

  new_movies_by_actor = get_movies_starring_actor(active_actor, active_node[:conn_movies])
  next if new_movies_by_actor.empty?

  active_node[:degrees] += 1  # update counter each time we see this node...

  new_movies_by_actor.each do |movie_id|
    fresh_node = deep_copy_node(active_node)
    fresh_node[:conn_movies] << movie_id
    actor_pool = get_actors_given_movie(movie_id)

    if actor_pool.include?(MARKS_ID)
      fresh_node[:conn_actors] << MARKS_ID
      @solved_nodes << fresh_node
    else
      # make children nodes for future searching:
      actor_pool.each do |actor_id|
        child_node = deep_copy_node(fresh_node)
        child_node[:conn_actors] << actor_id
        nodes << child_node
      end
    end
  end
  print "+"
end


#################
# PRINT RESULTS #
#################

if @solved_nodes.empty?
  puts "errr... no solutions found..."
else
  puts "\nOK... drum roll please..."
  paths = get_best_solved_nodes
  paths.each.with_index(1) do |path, index|
    puts "\n\nPath #{index}: Degrees: #{path[:degrees]}"
    [path[:conn_actors],path[:conn_movies]].flatten.each do |_|
      actor_name = csv_lookup(0, 1, "#{path[:conn_actors].pop}", @actors_csv)
      movie_name = csv_lookup(0, 1, path[:conn_movies].pop, movies_csv)
      puts "Actor: #{actor_name}" if !actor_name.empty?
      puts "Movie: #{movie_name}" if !movie_name.empty?
    end
  end
end





