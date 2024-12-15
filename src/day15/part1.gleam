import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import lib/utils
import simplifile

const filepath = "./src/day15/input.txt"

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

fn parse_map(m: String) -> #(utils.Coordinate, utils.Map) {
  let entities =
    string.split(m, "\n")
    |> list.index_map(fn(row, y) {
      string.to_graphemes(row)
      |> list.index_map(fn(char, x) { #(#(y, x), char) })
    })
    |> list.flatten
    |> list.fold([], fn(acc, item) {
      let #(pos, char) = item
      case char {
        "#" -> [#(pos, "#"), ..acc]
        "O" -> [#(pos, "O"), ..acc]
        "@" -> [#(pos, "@"), ..acc]
        _ -> acc
      }
    })

  let assert Ok(#(#(robot, _), coordinates)) =
    list.pop(entities, fn(e) {
      case e {
        #(_, "@") -> True
        _ -> False
      }
    })

  #(robot, dict.from_list(coordinates))
}

fn parse_instructions(i: String) -> List(Direction) {
  string.split(i, "\n")
  |> string.join("")
  |> string.to_graphemes
  |> list.map(fn(char) {
    case char {
      "^" -> Up
      ">" -> Right
      "v" -> Down
      "<" -> Left
      _ -> panic
    }
  })
}

fn move(
  robot: utils.Coordinate,
  dir: Direction,
  map: utils.Map,
) -> #(utils.Coordinate, utils.Map) {
  let next = next_pos(robot, dir)
  case dict.get(map, next) {
    Error(_) -> #(next, map)
    Ok("#") -> #(robot, map)
    Ok("O") ->
      case scan(next, dir, map) {
        Error(_) -> #(robot, map)
        Ok(slot) -> {
          let new_map =
            map
            |> dict.insert(slot, "O")
            |> dict.delete(next)
          #(next, new_map)
        }
      }
    _ -> panic
  }
}

fn scan(pos: utils.Coordinate, dir: Direction, map: utils.Map) {
  let next = next_pos(pos, dir)
  case dict.get(map, next) {
    Error(_) -> Ok(next)
    Ok("O") -> scan(next, dir, map)
    Ok("#") -> Error(Nil)
    _ -> panic
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)
  let assert [map_string, instruction_string] = string.split(contents, "\n\n")

  let #(robot, map) = parse_map(map_string)
  let instructions = parse_instructions(instruction_string)

  let #(_, final_map) =
    instructions
    |> list.fold(#(robot, map), fn(curr, dir) {
      let #(robot, map) = curr
      move(robot, dir, map)
    })

  final_map
  |> dict.to_list
  |> list.filter(fn(x) { x.1 == "O" })
  |> list.map(pair.first)
  |> list.map(fn(x) { x.0 * 100 + x.1 })
  |> int.sum
  |> io.debug
}
