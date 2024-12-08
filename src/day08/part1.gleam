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

fn get_antinodes(a: #(Int, Int), b: #(Int, Int)) {
  let dist = distance(a, b)
  #(antinode(a, dist, int.add), antinode(b, dist, int.subtract))
}

pub fn main() {
  let map = utils.get_map(filepath)

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
  |> utils.deep_map(fn(x) { get_antinodes(x.0, x.1) })
  |> list.flat_map(fn(x) { list.flat_map(x, fn(item) { [item.0, item.1] }) })
  |> list.unique
  |> list.map(dict.has_key(map, _))
  |> list.filter(function.identity)
  |> list.length
  |> io.debug
}
