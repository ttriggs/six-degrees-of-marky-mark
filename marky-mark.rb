#!/usr/bin/env ruby
require 'csv'
require_relative 'lookup'
require_relative 'branch'
require_relative 'tree'
require_relative 'solver'

if ARGV.length != 1
  puts "usage: #{__FILE__} \"<actor name>\""
  exit(1)
end

# DEFAULTS:
TARGET_ACTOR_ID = 1841
MAX_SOLUTIONS = 3

input_actor  = ARGV[0]

tree = Tree.new(input_actor, MAX_SOLUTIONS)
tree.solve_for_target(TARGET_ACTOR_ID)
tree.print_solutions
