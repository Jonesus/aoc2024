import gleam/function
import gleam/int
import gleam/io
import gleam/list
import lib/utils

const filepath = "./src/day02/input.txt"

fn levels_are_safe(levels: List(Int)) {
  list.all(levels, fn(x) { x >= -3 && x < 0 })
  || list.all(levels, fn(x) { x > 0 && x <= 3 })
}

fn deep_map(xs: List(List(a)), applicator: fn(a) -> b) -> List(List(b)) {
  list.map(xs, list.map(_, applicator))
}

pub fn main() {
  filepath
  |> utils.file_to_lines
  |> list.map(utils.string_to_ints)
  |> list.map(fn(line) { list.combinations(line, list.length(line) - 1) })
  |> deep_map(list.window_by_2)
  |> list.map(deep_map(_, fn(x) { x.0 - x.1 }))
  |> deep_map(levels_are_safe)
  |> list.map(list.any(_, function.identity))
  |> list.count(function.identity)
  |> int.to_string
  |> io.println
}
