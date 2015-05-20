class Tree
  attr_accessor :unsolved_branches, :solved_branches

  def initialize(input_actor, max_solutions)
    @max_solutions = max_solutions
    @lookup = Lookup.new
    @solved_branches = []
    input_actor_id = @lookup.actor_id_from_name(input_actor)
    @unsolved_branches = [ Branch.new(input_actor_id) ]
    @solver = Solver.new(self, @lookup)
  end

  def solve_for_target(actor_id)
    @solver.go!(actor_id)
  end

  def shortest_solution
    @solved_branches.map { |branch| branch.degrees }.min
  end

  def take_next!
    @unsolved_branches.shift
  end

  def found_all_solutions?
    @solved_branches.length >= @max_solutions
  end

  def solver_finished?
    trim_branches!
    @unsolved_branches.empty?
  end

  def trim_branches!
    @unsolved_branches = @unsolved_branches.drop_while do |branch|
      skip_branch?(branch)
    end
  end

  def skip_branch?(branch)
    found_all_solutions? || branch.worse_than?(shortest_solution)
  end

  def print_actor_name(id)
    actor_name = @lookup.actor_name_by_id(id)
    puts "Actor: #{actor_name}" if actor_name
  end

  def print_movie_name(id)
    movie_name = @lookup.movie_name_by_id(id)
    puts "Movie: #{movie_name}" if movie_name
  end

  def print_solutions
    if @solved_branches.empty?
      puts "errr... no solutions found..."
    else
      puts "OK... drum roll please...\n"
      @solved_branches.each.with_index(1) do |branch, path_num|
        puts "\n"
        puts "Path #{path_num}: Degrees: #{branch.degrees}"
        branch.actors.each_with_index do |actor_id, index|
          print_actor_name(actor_id)
          print_movie_name(branch.movies[index])
        end
      end
    end
  end

end
