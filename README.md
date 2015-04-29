# Six Degrees of Marky Mark

[I would suggest rewriting this with a database (like Postgres), which would speed up the search quite a bit.]

## About
A spin off of the popular six degrees of Kevin Bacon parlor game. This is my first attempt at a shortest path algorithm.

[Can you list what shortest path algorithm you used here? like a wikipedia link or something similar. Then spend a bit of time discussing how this algorithm works in words.]

Supply `marky-mark.rb` with an actor's name and it will compute the shortest distance path (using movies as nodes) to a Mark Wahlberg film. Currently, the algorithm is designed to disply a maximum of three equidistant shortest path solutions (this is stored as the constant MAX_SOLVED_PATHS. If you'd like to explore this more, fork this repo and increase this number (it turns out that Frank Sinatra has over 75 equivalent distance paths to Marky Mark!).

More about this implementation can be found here:
https://tylertriggs.wordpress.com/2015/03/29/six-degrees-of-marky-mark/

[I would just duplicate what's in your blog in your readme here as long as you've answered the question around how the algorithm works.]


#Sample Usage:
```
  ./marky-mark.rb "Pauly Shore"
  OK... drum roll please...
  Path 1: Degrees: 2
  Actor: Mark Wahlberg
  Movie: Max Payne
  Actor: Ludacris
  Movie: The Wash
  Actor: Pauly Shore
```

#Note:
The algorithm uses a pre-defined database of movies, actors, and a joining table called "cast_members.csv" but it could be extended to a more comprehensive database.
