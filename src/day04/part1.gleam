import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/utils

const filepath = "./src/day04/input.txt"

pub fn get_map(filename: String) {
  filename
  |> utils.file_to_lines
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

pub fn get_starts(map: dict.Dict(#(Int, Int), String), target_value: String) {
  dict.to_list(map)
  |> list.unzip
  |> fn(x) { list.zip(x.1, x.0) }
  |> list.filter(fn(x) { x.0 == target_value })
  |> list.map(fn(x) { x.1 })
}

pub fn to(x: #(Int, Int), dir: #(Int, Int)) {
  #(x.0 + dir.0, x.1 + dir.1)
}

fn traverse(
  x: #(Int, Int),
  dir: #(Int, Int),
  route: List(String),
  d: dict.Dict(#(Int, Int), String),
) -> Int {
  case route {
    [target, ..rest] -> {
      let moved = to(x, dir)
      case dict.get(d, moved) {
        Ok(letter) if letter == target -> traverse(moved, dir, rest, d)
        Ok(_) | Error(_) -> 0
      }
    }
    [] -> 1
  }
}

pub fn main() {
  let dirs = {
    let ys = list.range(from: -1, to: 1)
    let xs = list.range(from: -1, to: 1)

    list.flat_map(ys, fn(y) { list.map(xs, fn(x) { #(y, x) }) })
    |> list.filter(fn(item) { item != #(0, 0) })
  }

  let map = get_map(filepath)
  let starts = get_starts(map, "X")

  starts
  |> list.map(fn(start) {
    list.map(dirs, traverse(start, _, ["M", "A", "S"], map))
    |> int.sum
  })
  |> int.sum
  |> int.to_string
  |> io.println
}
