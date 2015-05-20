class Solver
  def initialize(tree, lookup)
    @tree = tree
    @cycles = 0
    @lookup = lookup
  end

  def go!(target_actor_id)
    @target_actor_id = target_actor_id
    until @tree.solver_finished?
      active_branch = @tree.take_next!
      seed_actor = active_branch.seed_actor
      new_movies_with_actor = @lookup.movies_with_actor(seed_actor,
                                                        active_branch.movies)
      next if new_movies_with_actor.empty?
      active_branch.increment_degrees
      process_movie_branches(new_movies_with_actor, active_branch)
      print "+"
      @cycles += 1
    end
    puts ""
  end

  def process_movie_branches(new_movies_with_actor, active_branch)
    new_movies_with_actor.each do |movie_id|
      fresh_branch = active_branch.deep_copy
      fresh_branch.movies << movie_id
      actor_pool = @lookup.actors_given_movie(movie_id)
      if actor_pool.include?(@target_actor_id)
        mark_solved_route(fresh_branch)
      else
        add_child_nodes_to_list(actor_pool, fresh_branch)
      end
    end
  end

  def mark_solved_route(fresh_branch)
    fresh_branch.actors << @target_actor_id
    @tree.solved_branches << fresh_branch
  end

  def add_child_nodes_to_list(actor_pool, fresh_branch)
    actor_pool.each do |actor_id|
      child_branch = fresh_branch.deep_copy
      child_branch.actors << actor_id
      @tree.unsolved_branches << child_branch
    end
  end
end
