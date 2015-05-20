class Lookup
  def initialize
    @cast_csv    = './cast_members.csv'
    @actors_csv  = './actors.csv'
    @movies_csv  = './movies.csv'
    @cast_hash   = init_cast_hash
  end

  def init_cast_hash
    hash = {}
    CSV.foreach(@cast_csv) do |actor_id, movie_id|
      hash["#{movie_id}"] = [] unless hash.has_key?("#{movie_id}")
      hash["#{movie_id}"] << actor_id.to_i
    end
    hash
  end

  def actor_id_from_name(actor_name)
    actor_id = in_csv(1, 0, actor_name, @actors_csv)
    if actor_id.empty?
      puts "Sorry, #{actor_name} not found in our DB!"
      exit 1
    end
    actor_id.to_i
  end

  def movies_with_actor(actor_id, movies_already_in_tree)
    movies = @cast_hash.select { |k,v| k if v.include?(actor_id) }.keys
    movies - movies_already_in_tree
  end

  def in_csv(look_index, return_index, match, csv_file)
    answer = ""
    CSV.foreach(csv_file) do |row|
      answer = row[return_index] if row[look_index] == match
    end
    answer
  end

  def actor_name_by_id(id)
    in_csv(0, 1, "#{id}", @actors_csv) if id
  end

  def movie_name_by_id(id)
    in_csv(0, 1, id, @movies_csv) if id
  end

  def actors_given_movie(movie_id)
    @cast_hash.select {|k,v| k if k == "#{movie_id}" }.values[0]
  end
end




