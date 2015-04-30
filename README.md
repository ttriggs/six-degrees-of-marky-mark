# Six Degrees of Marky Mark

## About
One of the optional challenges at Launch Academy is to write an algorithm that finds the shortest path between a given actor and Mark Wahlberg (or as he's known from his 90's hip hop days, [Marky Mark](http://en.wikipedia.org/wiki/Marky_Mark_and_the_Funky_Bunch). In other words, it is a spin off from the popular parlor game [six degrees of Kevin Bacon](http://en.wikipedia.org/wiki/Six_Degrees_of_Kevin_Bacon) for practice coding a shortest path algorithm.

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

###A quick overview of how it works:

Using the above sample solution, the algorithm first finds all movies "Pauly Shore" was cast in as a potential first step, or "node' in the path to finding Mark Wahlberg. Using this list of movies, it goes through each one, finds the actors cast the movie, and looks for Mark. If Mark is found, that path is labeled as "solved" and is removed from further searches. If Mark isn't found, a copy of the path is made for each of the actors in the connecting movie.

In our demo database (csv files included), Pauly Shore is cast in five movies. In his movie "The Wash" there are 33 other associated actors. Because Marky Mark is not in this movie, each of the 33 "The Wash" actors become the starting point for the next round of searching. This addition of a movie & actor to a path causes elongation of the path (distance here is expressed in "degrees").

The next important decision is to put these elongated paths at the end of the searching queue. By design this is a [breadth first](http://en.wikipedia.org/wiki/Breadth-first_search) search style as opposed to [depth first](http://en.wikipedia.org/wiki/Depth-first_search). Both styles can arrive at the same result, but because we are interested in the shortest path, we achieve a boost in search time performance by always focusing CPU power on the shortest paths first. However, in order to realize this performance boost, some additional logic needs to be added to the algorithm. Primarily, we don't want to perform a search on a path if we've already found a shorter or equivalent distance path. So if the next path in the search queue is longer than our best solution, that path can be aborted.

In my solution, I designed the algorithm to find a maximum of three equivalent shortest-distance paths (mostly just for fun). A simple way to better optimize the performance of this algorithm would be to abort all paths as soon as a solution is found... but hey, wouldn't it be cool to see all the different ways Frank Sinatra can be connected to Marky Mark!? (in our demo database, Ol' Blue Eyes has over 75 equivalent-distance paths!)

###Note:
The algorithm uses a pre-defined database of movies, actors, and a joining table called "cast_members.csv" but it could be extended to a more comprehensive database.

