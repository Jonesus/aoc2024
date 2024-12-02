import gleam/function
import gleam/int
import gleam/io
import gleam/list
import lib/utils

const filepath = "./src/day02/input.txt"

pub fn main() {
  filepath
  |> utils.file_to_lines
  |> list.map(utils.string_to_ints)
  |> list.map(list.window_by_2)
  |> list.map(fn(line) { list.map(line, fn(x) { x.0 - x.1 }) })
  |> list.map(fn(line) {
    list.all(line, fn(x) { x >= -3 && x < 0 })
    || list.all(line, fn(x) { x > 0 && x <= 3 })
  })
  |> list.count(function.identity)
  |> int.to_string
  |> io.println
}
