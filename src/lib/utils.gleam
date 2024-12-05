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
