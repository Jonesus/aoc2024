import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import lib/utils

const filepath = "./src/day12/input.txt"

// Name, edges, squares
type Region =
  #(String, List(#(Int, Int)), List(#(Int, Int)))

type Direction {
  Up
  Down
  Left
  Right
}

fn next_pos(pos: utils.Coordinate, dir: Direction) -> utils.Coordinate {
  case dir {
    Up -> #(pos.0 - 1, pos.1)
    Down -> #(pos.0 + 1, pos.1)
    Left -> #(pos.0, pos.1 - 1)
    Right -> #(pos.0, pos.1 + 1)
  }
}

fn neighbors(pos: utils.Coordinate) -> List(utils.Coordinate) {
  [Up, Down, Left, Right]
  |> list.map(fn(dir) { next_pos(pos, dir) })
}

fn neighbors_region(pos: utils.Coordinate, reg: Region) {
  let #(_, edges, _) = reg
  list.contains(edges, pos)
}

fn place_in_region(
  x: #(utils.Coordinate, String),
  possibles: List(Region),
) -> List(Region) {
  case possibles {
    [] -> {
      [#(x.1, neighbors(x.0), [x.0])]
    }
    [candidate, ..rest] -> {
      case neighbors_region(x.0, candidate) {
        True -> {
          [
            #(candidate.0, list.flatten([candidate.1, neighbors(x.0)]), [
              x.0,
              ..candidate.2
            ]),
            ..rest
          ]
        }
        False -> [candidate, ..place_in_region(x, rest)]
      }
    }
  }
}

fn merge_regions(a: Region, b: Region) -> Region {
  #(a.0, list.flatten([a.1, b.1]), list.flatten([a.2, b.2]))
}

fn adjacent_regions(a: Region, b: Region) -> Bool {
  list.any(b.2, fn(square) { list.contains(a.1, square) })
  || list.any(a.2, fn(square) { list.contains(b.1, square) })
}

fn deep_merge(regions: List(Region)) -> List(Region) {
  case regions {
    [] -> []
    [r1, ..rest] -> {
      case list.pop(rest, fn(x) { adjacent_regions(r1, x) }) {
        Ok(#(r2, rest2)) -> {
          deep_merge([merge_regions(r1, r2), ..rest2])
        }
        Error(_) -> [r1, ..deep_merge(rest)]
      }
    }
  }
}

fn filter_edges(reg: Region) -> Region {
  let #(name, edges, squares) = reg
  let filtered_edges =
    list.filter(edges, fn(edge) { bool.negate(list.contains(squares, edge)) })
  #(name, filtered_edges, squares)
}

pub fn main() {
  let map = utils.get_map(filepath)

  map
  |> dict.to_list
  |> list.group(fn(x) { x.0.0 })
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.flat_map(fn(x) {
    x.1
    |> list.sort(fn(a, b) { int.compare(a.0.1, b.0.1) })
  })
  |> list.fold([], fn(regions: List(Region), x) {
    let #(possibles, rest) = list.partition(regions, fn(r) { r.0 == x.1 })
    list.flatten([place_in_region(x, possibles), rest])
  })
  |> list.group(fn(x) { x.0 })
  |> dict.to_list
  |> list.map(fn(x) {
    let #(_, regions) = x
    deep_merge(regions)
  })
  |> list.flatten
  |> list.map(filter_edges)
  |> list.map(fn(region) { list.length(region.1) * list.length(region.2) })
  |> int.sum
  |> io.debug
}
