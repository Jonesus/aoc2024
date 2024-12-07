import day06/part1
import gleam/erlang/process

import gleam/bool
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/pair
import gleam/string
import lib/utils

const filepath = "./src/day06/input.txt"

fn debug(map: utils.Map, g: part1.Guard) {
  map
  |> dict.to_list
  |> list.map(fn(x) {
    case x.1 {
      "^" -> #(x.0, ".")
      _ -> x
    }
  })
  |> list.map(fn(x) {
    case x.0 {
      curr if curr == g.0 -> {
        case g.1 {
          part1.Up -> #(x.0, "^")
          part1.Right -> #(x.0, ">")
          part1.Down -> #(x.0, "v")
          part1.Left -> #(x.0, "<")
        }
      }
      _ -> x
    }
  })
  |> list.group(fn(x) { x.0.0 })
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(x) {
    x.1
    |> list.sort(fn(a, b) { int.compare(a.0.1, b.0.1) })
    |> list.map(pair.second)
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
}

fn travel(
  map: utils.Map,
  g: part1.Guard,
  turns: List(utils.Coordinate),
  blocks: List(utils.Coordinate),
) -> List(utils.Coordinate) {
  debug(map, g)
  process.sleep(100)
  let target_pos = part1.get_next_pos(g)
  case dict.get(map, target_pos) {
    Error(_) -> blocks
    Ok("#") -> travel(map, part1.turn(g), [g.0, ..turns], blocks)
    Ok(_) -> {
      let relevant =
        list.range(0, list.length(turns) - 1)
        |> list.zip(turns)
        |> list.filter(fn(x) { x.0 % 4 == 2 })
        |> list.map(pair.second)
      let new_blocks = case g.1 {
        part1.Left | part1.Right -> {
          case list.map(relevant, pair.second) |> list.contains(target_pos.1) {
            True -> {
              //debug(map, part1.move_forward(g))
              //io.debug(turns)
              //io.debug(relevant)
              //io.debug("\n")
              map
              |> dict.insert(part1.move_forward(part1.move_forward(g)).0, "O")
              |> debug(part1.move_forward(g))
              process.sleep(2000)

              [part1.move_forward(part1.move_forward(g)).0, ..blocks]
            }
            False -> blocks
          }
        }
        part1.Up | part1.Down -> {
          case list.map(relevant, pair.first) |> list.contains(target_pos.0) {
            True -> {
              //debug(map, part1.move_forward(g))
              //io.debug(turns)
              //io.debug(relevant)
              //io.debug("\n")
              map
              |> dict.insert(part1.move_forward(part1.move_forward(g)).0, "O")
              |> debug(part1.move_forward(g))
              process.sleep(2000)

              [part1.move_forward(part1.move_forward(g)).0, ..blocks]
            }
            False -> blocks
          }
        }
      }
      travel(map, part1.move_forward(g), turns, new_blocks)
    }
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

  travel(map, #(start, part1.Up), [], [])
  |> list.unique
  |> list.length
  |> int.to_string
  //|> io.println
}
