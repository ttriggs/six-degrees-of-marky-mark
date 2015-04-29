#!/usr/bin/env ruby
require 'csv'
require 'ruby-prof'

RubyProf.start

if ARGV.length != 1
  puts "usage: #{__FILE__} \"<actor name>\""
  exit(1)
end

# REMOVE YOUR COMMENTS IN HERE AND RENAME VARIABLES/METHODS IF THEY NEED TO BE CLARIFIED
# RIGHT NOW YOU'RE RUNNING THROUGH THE CSV EACH TIME YOU RUN THE PROGRAM. WOULDN'T IT
# MAKE MORE SENSE TO GENERATE A SINGLE HASH THAT YOU CAN RUN THROUGH?
# YOU COULD HAVE A SEEDER FILE THAT GENERATES THAT HASH ONCE
# OR YOU COULD JUST UPDATE THIS TO A DATABASE FOR SPEED
# USE A PROFILER TO SEE WHICH METHODS ARE TAKING THE LONGEST TO SPEED UP YOUR APP
# I ADDED RUBY PROFILER HERE AND COMMENTED OUT RESULTS AT THE BOTTOM OF THIS FILE
# TAKE A LOOK AND SEE IF YOU CAN FIGURE OUT WHERE THE BOTTLENECKS ARE COMING FROM

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
  print "+" #CAN YOU ADD A PERCENTAGE HERE? LIKE HOW FAR THE ALGORITHM IS FROM FINISHING?
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

result = RubyProf.stop

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)

# hread ID: 70116918516720
# Fiber ID: 70116923296780
# Total: 37.625309
# Sort by: self_time

#  %self      total      self      wait     child     calls  name
#  23.06     16.722     8.678     0.000     8.045   517352   Array#include?
#  21.38      8.045     8.045     0.000     0.000 13526145   Fixnum#==
#  15.39     12.734     5.791     0.000     6.944   430298   Kernel#loop
#   7.04     19.350     2.649     0.000    16.701      635   Hash#select
#   5.41     16.267     2.035     0.000    14.232   430298   CSV#shift
#   3.24     14.508     1.219     0.000    13.290   447179  *Array#each
#   2.89     17.563     1.088     0.000    16.475       12   CSV#each
#   2.55      0.959     0.959     0.000     0.000   430286   String#sub!
#   2.45      0.923     0.923     0.000     0.000   860584   String#=~
#   1.93      0.725     0.725     0.000     0.000   864217   String#[]
#   1.78      0.981     0.672     0.000     0.310   430406  *Class#new
#   1.61      0.606     0.606     0.000     0.000   430286   String#split
#   1.59      0.597     0.597     0.000     0.000   430310   IO#gets
#   1.39      0.522     0.522     0.000     0.000   430298   CSV#header_row?
#   0.81      0.304     0.304     0.000     0.000   430322   Array#initialize
#   0.54      0.310     0.202     0.000     0.107    16923   <Module::Marshal>#dump
#   0.30      0.114     0.114     0.000     0.000   178605   Kernel#respond_to_missing?
#   0.26      0.096     0.096     0.000     0.000    91990   String#to_i
#   0.25      0.092     0.092     0.000     0.000    91989   Hash#has_key?
#   0.21      0.081     0.081     0.000     0.000    16923   <Module::Marshal>#load
#   0.13      0.143     0.048     0.000     0.095    16436   Object#keep_node?
#   0.11      0.434     0.043     0.000     0.391    16923   Object#deep_copy_node
#   0.11      0.095     0.043     0.000     0.052    16437   Object#best_solved_degrees
#   0.10     37.625     0.038     0.000    37.588        1   Global#[No method]
#   0.06      0.022     0.022     0.000     0.001    16409   Array#map
#   0.05      0.030     0.020     0.000     0.010    16313   Enumerable#min
#   0.03      0.019     0.013     0.000     0.006    10653   String#==
#   0.03      0.011     0.011     0.000     0.000    16436   Array#shift
#   0.02      0.007     0.007     0.000     0.000     1398   String#gsub!
#   0.01      0.003     0.003     0.000     0.000     3702   Array#last
#   0.00      1.753     0.002     0.000     1.751      488   Object#get_actors_given_movie
#   0.00      0.002     0.002     0.000     0.000     1398   String#count
#   0.00      0.002     0.002     0.000     0.000      104   IO#write
#   0.00      0.002     0.002     0.000     0.000     1398   String#*
#   0.00      0.001     0.001     0.000     0.000      147   Array#-
#   0.00      0.001     0.001     0.000     0.000      488   Hash#values
#   0.00     17.603     0.001     0.000    17.602      147   Object#get_movies_starring_actor
#   0.00      0.002     0.001     0.000     0.002       12   CSV#init_separators
#   0.00      0.001     0.001     0.000     0.000      147   Hash#keys
#   0.00      0.006     0.001     0.000     0.005       12   CSV#initialize
#   0.00      0.000     0.000     0.000     0.000      288   String#encode
#   0.00      0.000     0.000     0.000     0.000       12   File#initialize
#   0.00      0.000     0.000     0.000     0.000       60   Regexp#initialize
#   0.00      0.001     0.000     0.000     0.000       24   CSV#init_converters
#   0.00      0.000     0.000     0.000     0.000      147   Object#get_active_actor
#   0.00      0.002     0.000     0.000     0.001       90   Kernel#print
#   0.00     17.570     0.000     0.000    17.570       12   <Class::CSV>#open
#   0.00      0.001     0.000     0.000     0.001       96   CSV#encode_str
#   0.00      0.000     0.000     0.000     0.000      192   Hash#delete
#   0.00      0.000     0.000     0.000     0.000      228   Encoding#name
#   0.00      0.002     0.000     0.000     0.002       12   CSV#init_parsers
#   0.00      0.001     0.000     0.000     0.001       60   CSV#encode_re
#   0.00      0.000     0.000     0.000     0.000       12   IO#close
#   0.00      0.000     0.000     0.000     0.000       24   String#gsub
#   0.00      0.000     0.000     0.000     0.000       96   Array#join
#   0.00     10.370     0.000     0.000    10.370        1   Enumerator#with_index
#   0.00      0.000     0.000     0.000     0.000       24   Hash#initialize_copy
#   0.00      0.000     0.000     0.000     0.000       12   CSV#init_headers
#   0.00     12.829     0.000     0.000    12.829       11   Object#csv_lookup
#   0.00      0.000     0.000     0.000     0.000       24   String#sub
#   0.00      0.000     0.000     0.000     0.000       24   Hash#merge
#   0.00      0.000     0.000     0.000     0.000       12   CSV#raw_encoding
#   0.00      0.000     0.000     0.000     0.000       12   CSV#close
#   0.00      0.000     0.000     0.000     0.000       24   Kernel#method
#   0.00      0.000     0.000     0.000     0.000       24   Kernel#initialize_dup
#   0.00      0.000     0.000     0.000     0.000       24   Kernel#instance_variable_set
#   0.00      0.000     0.000     0.000     0.000       48   Symbol#to_s
#   0.00      0.000     0.000     0.000     0.000       36   Kernel#is_a?
#   0.00      0.000     0.000     0.000     0.000       12   CSV#init_comments
#   0.00      0.000     0.000     0.000     0.000       48   Symbol#==
#   0.00      0.000     0.000     0.000     0.000       24   Kernel#lambda
#   0.00      0.000     0.000     0.000     0.000       24   CSV#escape_re
#   0.00     17.570     0.000     0.000    17.570       12   <Class::CSV>#foreach
#   0.00      0.000     0.000     0.000     0.000       48   BasicObject#==
#   0.00      0.000     0.000     0.000     0.000       12   <Class::IO>#open
#   0.00      0.000     0.000     0.000     0.000       12   IO#rewind
#   0.00      0.000     0.000     0.000     0.000       12   IO#pos
#   0.00      0.000     0.000     0.000     0.000       36   String#to_s
#   0.00      0.000     0.000     0.000     0.000        7   IO#puts
#   0.00      0.000     0.000     0.000     0.000       22   Array#pop
#   0.00      0.000     0.000     0.000     0.000       12   Numeric#nonzero?
#   0.00      0.000     0.000     0.000     0.000        7   Kernel#puts
#   0.00      0.000     0.000     0.000     0.000       24   Kernel#block_given?
#   0.00      0.000     0.000     0.000     0.000       24   NilClass#nil?
#   0.00      0.000     0.000     0.000     0.000       12   Kernel#respond_to?
#   0.00      0.000     0.000     0.000     0.000       12   Hash#initialize
#   0.00      0.000     0.000     0.000     0.000       12   IO#external_encoding
#   0.00      0.000     0.000     0.000     0.000       12   String#end_with?
#   0.00      0.000     0.000     0.000     0.000       12   IO#internal_encoding
#   0.00      0.000     0.000     0.000     0.000       12   Fixnum#zero?
#   0.00      0.000     0.000     0.000     0.000        1   Array#flatten
#   0.00      0.000     0.000     0.000     0.000        5   Fixnum#to_s
#   0.00      0.000     0.000     0.000     0.000       10   Module#method_added
#   0.00      0.000     0.000     0.000     0.000        1   Object#get_best_solved_nodes
#   0.00      0.000     0.000     0.000     0.000        2   NilClass#to_s
#   0.00      2.459     0.000     0.000     2.459        1   Object#get_actor_id_from_name
#   0.00      0.000     0.000     0.000     0.000        1   Array#select
