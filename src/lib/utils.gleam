import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

/// This function reads a file to a list of lines
pub fn file_to_lines(filename: String) {
  let assert Ok(contents) = simplifile.read(filename)
  string.split(contents, on: "\n")
}

/// This function parses a string of space-delimited integers to a list of integers.
/// We naively assume the parsing to never fail, otherwise we panic.
pub fn string_to_ints(str: String) {
  str
  |> string.split(on: " ")
  |> list.map(fn(item) {
    case int.parse(item) {
      Ok(x) -> x
      _ -> panic as "lol"
    }
  })
}

/// This function applies a functor to each item in a nested list
pub fn deep_map(xs: List(List(a)), applicator: fn(a) -> b) -> List(List(b)) {
  list.map(xs, list.map(_, applicator))
}

/// This function takes in a list of ints and prints out their sum
pub fn print_sum(x: List(Int)) {
  x
  |> int.sum
  |> int.to_string
  |> io.println
}

/// A pair representing some coordinate in the form of Y,X
pub type Coordinate =
  #(Int, Int)

/// Dict representing a 2D grid of single characters, where the key is a
/// pair of Y,X coordinates and the value is any single character
pub type Map =
  dict.Dict(Coordinate, String)

/// Reads a file that consists of a 2D grid of single characters, and returns
/// a dict with keys for each coordinate pair and values of the characters
pub fn get_map(filename: String) -> Map {
  filename
  |> file_to_lines
  |> list.map(string.to_graphemes)
  |> list.index_fold(dict.new(), fn(acc, curr, j) {
    let indexed =
      list.zip(
        list.repeat(j, times: list.length(curr)),
        list.range(0, list.length(curr) - 1),
      )
    acc
    |> dict.merge(dict.from_list(list.zip(indexed, curr)))
  })
}

/// Transform a list of items into a list of pairs with first element as index
/// and second element as the original element
pub fn index(l: List(a)) -> List(#(Int, a)) {
  list.range(0, list.length(l) - 1)
  |> list.zip(l)
}
