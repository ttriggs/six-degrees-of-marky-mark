class Branch
  FAIL_LENGTH  = 8
  attr_accessor :movies, :actors, :degrees

  def initialize(input_actor_id)
    @actors = [input_actor_id]
    @movies = []
    @degrees = 0
  end

  def worse_than?(best_solved_degrees)
    upper_limit = (best_solved_degrees || FAIL_LENGTH)
    @degrees >= upper_limit
  end

  def seed_actor
    @actors[-1]
  end

  def found_mark?(actor_array)
    actor_array.include?(TARGET_ACTOR_ID)
  end

  def increment_degrees
    @degrees += 1
  end

  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end
