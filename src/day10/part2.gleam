import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import lib/utils

const filepath = "./src/day10/input.txt"

type Direction {
  Up
  Down
  Left
  Right
}

type Map =
  dict.Dict(utils.Coordinate, Int)

fn next_pos(pos: utils.Coordinate, dir: Direction) -> utils.Coordinate {
  case dir {
    Up -> #(pos.0 - 1, pos.1)
    Down -> #(pos.0 + 1, pos.1)
    Left -> #(pos.0, pos.1 - 1)
    Right -> #(pos.0, pos.1 + 1)
  }
}

fn travel(
  pos: utils.Coordinate,
  height: Int,
  tail: List(utils.Coordinate),
  map: Map,
) -> List(List(utils.Coordinate)) {
  [Up, Right, Down, Left]
  |> list.map(next_pos(pos, _))
  |> list.map(fn(next) {
    case dict.get(map, next) {
      Ok(h) if h - height == 1 && h == 9 -> [[next, ..tail]]
      Ok(h) if h - height == 1 -> travel(next, h, [next, ..tail], map)
      _ -> []
    }
  })
  |> list.flatten
}

pub fn main() {
  let map =
    utils.get_map(filepath)
    |> dict.to_list
    |> list.map(fn(x) {
      case pair.map_second(x, int.parse) {
        #(pos, Ok(height)) -> #(pos, height)
        _ -> panic
      }
    })
    |> dict.from_list

  let starts =
    dict.to_list(map)
    |> list.filter(fn(x) { pair.second(x) == 0 })
    |> list.map(pair.first)

  starts
  |> list.map(fn(start) { travel(start, 0, [start], map) })
  |> list.map(list.unique)
  |> list.map(list.length)
  |> int.sum
  |> io.debug
}
