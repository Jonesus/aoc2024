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

/// Prints the `string.inspect` value of given argument and returns the same value
pub fn debug(x: a) {
  io.println(string.inspect(x))
  x
}
