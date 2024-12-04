import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import lib/utils

const filepath = "./src/day03/input.txt"

pub fn match(str: String) {
  let assert Ok(re) = regexp.from_string("mul\\(([0-9]{0,3}),([0-9]{0,3})\\)")

  regexp.scan(with: re, content: str)
  |> list.map(fn(item) {
    let regexp.Match(_, captures) = item
    captures
    |> option.values
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))
  })
}

pub fn main() {
  filepath
  |> utils.file_to_lines
  |> string.concat
  |> match
  |> list.map(fn(numbers) {
    case numbers {
      [a, b] -> a * b
      _ -> panic
    }
  })
  |> int.sum
  |> int.to_string
  |> io.println
}
