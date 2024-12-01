import day01/part1.{get_lists}
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import simplifile

const filepath = "./src/day01/input.txt"

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  get_lists(contents)
  |> fn(x) { #(x.0, list.group(x.1, function.identity)) }
  |> fn(x) {
    list.map(x.0, fn(item) {
      case dict.get(x.1, item) {
        Ok(xs) -> item * list.length(xs)
        _ -> 0
      }
    })
  }
  |> int.sum
  |> int.to_string
  |> io.println
}
