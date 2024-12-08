import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import lib/utils

const filepath = "./src/day08/input.txt"

fn distance(a: #(Int, Int), b: #(Int, Int)) {
  #(a.0 - b.0, a.1 - b.1)
}

fn antinode(x: #(Int, Int), dist: #(Int, Int), op: fn(Int, Int) -> Int) {
  #(op(x.0, dist.0), op(x.1, dist.1))
}

fn get_antinodes(a: #(Int, Int), b: #(Int, Int), bounds: #(Int, Int)) {
  let dist = distance(a, b)
  let antia = recurse(a, dist, bounds, int.add)
  let antib = recurse(b, dist, bounds, int.subtract)
  list.flatten([[a, b], antia, antib])
}

fn recurse(
  x: #(Int, Int),
  dist: #(Int, Int),
  bounds: #(Int, Int),
  op: fn(Int, Int) -> Int,
) -> List(#(Int, Int)) {
  case antinode(x, dist, op) {
    node
      if node.0 >= 0 && node.0 <= bounds.0 && node.1 >= 0 && node.1 <= bounds.1
    -> [node, ..recurse(node, dist, bounds, op)]
    _ -> []
  }
}

pub fn main() {
  let map = utils.get_map(filepath)

  let assert Ok(bounds_y) =
    dict.to_list(map)
    |> list.map(pair.first)
    |> list.map(pair.first)
    |> list.reduce(int.max)

  let assert Ok(bounds_x) =
    dict.to_list(map)
    |> list.map(pair.first)
    |> list.map(pair.second)
    |> list.reduce(int.max)

  dict.to_list(map)
  |> list.filter(fn(x) { x.1 != "." })
  |> list.group(pair.second)
  // group per character
  |> dict.to_list
  |> list.map(pair.second)
  // remove dict keys
  |> utils.deep_map(pair.first)
  // strip out characters
  |> list.map(list.combination_pairs)
  |> utils.deep_map(fn(x) { get_antinodes(x.0, x.1, #(bounds_y, bounds_x)) })
  |> list.flat_map(list.flatten)
  |> list.unique
  |> list.map(dict.has_key(map, _))
  |> list.filter(function.identity)
  |> list.length
  |> io.debug
}
