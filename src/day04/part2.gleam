import day04/part1.{get_map, get_starts, to}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result

const filepath = "./src/day04/input.txt"

const topleft = #(-1, -1)

const topright = #(-1, 1)

const bottomright = #(1, 1)

const bottomleft = #(1, -1)

fn has_xmas(a: #(Int, Int), d: dict.Dict(#(Int, Int), String)) {
  let dirs =
    [topleft, topright, bottomright, bottomleft]
    |> list.map(fn(dir) { dict.get(d, to(a, dir)) })
    |> result.values()

  case dirs {
    ["M", "M", "S", "S"]
    | ["S", "M", "M", "S"]
    | ["S", "S", "M", "M"]
    | ["M", "S", "S", "M"] -> 1
    _ -> 0
  }
}

pub fn main() {
  let map = get_map(filepath)
  let starts = get_starts(map, "A")

  starts
  |> list.map(has_xmas(_, map))
  |> int.sum
  |> int.to_string
  |> io.println
}
