import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import lib/utils

const filepath = "./src/day06/test.txt"

pub type Direction {
  Up
  Down
  Left
  Right
}

pub type Guard =
  #(#(Int, Int), Direction)

pub fn get_next_pos(g: Guard) -> #(Int, Int) {
  let #(pos, dir) = g

  case dir {
    Up -> #(pos.0 - 1, pos.1)
    Down -> #(pos.0 + 1, pos.1)
    Left -> #(pos.0, pos.1 - 1)
    Right -> #(pos.0, pos.1 + 1)
  }
}

pub fn move_forward(g: Guard) -> Guard {
  #(get_next_pos(g), g.1)
}

pub fn turn(g: Guard) -> Guard {
  case g {
    #(pos, Up) -> #(pos, Right)
    #(pos, Right) -> #(pos, Down)
    #(pos, Down) -> #(pos, Left)
    #(pos, Left) -> #(pos, Up)
  }
}

pub fn travel(
  map: utils.Map,
  g: Guard,
  visited: List(utils.Coordinate),
) -> List(utils.Coordinate) {
  let target_pos = get_next_pos(g)
  case dict.get(map, target_pos) {
    Error(_) -> visited
    Ok("#") -> travel(map, turn(g), visited)
    Ok(_) -> travel(map, move_forward(g), [target_pos, ..visited])
  }
}

pub fn main() {
  let map = utils.get_map(filepath)

  let assert Ok(start) =
    dict.to_list(map)
    |> list.find_map(fn(x) {
      case pair.second(x) {
        "^" -> Ok(pair.first(x))
        _ -> Error("")
      }
    })

  travel(map, #(start, Up), [start])
  |> list.unique
  |> list.length
  |> int.to_string
  |> io.println
}
