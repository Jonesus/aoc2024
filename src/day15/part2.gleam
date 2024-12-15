import gleam/dict
import gleam/erlang/process
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
      let #(#(y, x), char) = item
      case char {
        "#" -> [#(#(y, 2 * x), "#"), #(#(y, 2 * x + 1), "#"), ..acc]
        "O" -> [#(#(y, 2 * x), "["), #(#(y, 2 * x + 1), "]"), ..acc]
        "@" -> [#(#(y, 2 * x), "@"), ..acc]
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

fn move_box(
  box: #(utils.Coordinate, utils.Coordinate),
  dir: Direction,
  map: utils.Map,
) -> Result(utils.Map, Nil) {
  let #(l, r) = box
  let #(nl, nr) = #(next_pos(l, dir), next_pos(r, dir))

  let candidate_map = map |> dict.delete(l) |> dict.delete(r)

  case dict.get(candidate_map, nl), dict.get(candidate_map, nr) {
    Error(_), Error(_) ->
      Ok(candidate_map |> dict.insert(nl, "[") |> dict.insert(nr, "]"))
    Error(_), Ok("[") if dir == Right ->
      case move_box(#(nr, next_pos(nr, dir)), dir, candidate_map) {
        Ok(new_map) ->
          Ok(new_map |> dict.insert(nl, "[") |> dict.insert(nr, "]"))
        err -> err
      }
    Ok("]"), Error(_) if dir == Left ->
      case move_box(#(next_pos(nl, dir), nl), dir, candidate_map) {
        Ok(new_map) ->
          Ok(new_map |> dict.insert(nl, "[") |> dict.insert(nr, "]"))
        err -> err
      }
    Error(_), Ok("[") if dir == Up || dir == Down ->
      case move_box(#(nr, next_pos(nr, Right)), dir, candidate_map) {
        Ok(new_map) ->
          Ok(new_map |> dict.insert(nl, "[") |> dict.insert(nr, "]"))
        err -> err
      }
    Ok("]"), Error(_) if dir == Up || dir == Down ->
      case move_box(#(next_pos(nl, Left), nl), dir, candidate_map) {
        Ok(new_map) ->
          Ok(new_map |> dict.insert(nl, "[") |> dict.insert(nr, "]"))
        err -> err
      }
    Ok("["), Ok("]") ->
      case move_box(#(nl, nr), dir, candidate_map) {
        Ok(new_map) ->
          Ok(new_map |> dict.insert(nl, "[") |> dict.insert(nr, "]"))
        err -> err
      }
    Ok("]"), Ok("[") ->
      case move_box(#(next_pos(nl, Left), nl), dir, candidate_map) {
        Ok(new_map) ->
          case move_box(#(nr, next_pos(nr, Right)), dir, new_map) {
            Ok(newer_map) ->
              Ok(newer_map |> dict.insert(nl, "[") |> dict.insert(nr, "]"))
            err -> err
          }
        err -> err
      }
    Ok(_), Ok(_) | Error(_), Ok(_) | Ok(_), Error(_) -> Error(Nil)
  }
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
    Ok("[") if dir == Right ->
      case move_box(#(next, next |> next_pos(dir)), dir, map) {
        Ok(new_map) -> #(next, new_map)
        Error(_) -> #(robot, map)
      }
    Ok("[") if dir == Up || dir == Down ->
      case move_box(#(next, next |> next_pos(Right)), dir, map) {
        Ok(new_map) -> #(next, new_map)
        Error(_) -> #(robot, map)
      }
    Ok("]") if dir == Left ->
      case move_box(#(next |> next_pos(dir), next), dir, map) {
        Ok(new_map) -> #(next, new_map)
        Error(_) -> #(robot, map)
      }
    Ok("]") if dir == Up || dir == Down ->
      case move_box(#(next |> next_pos(Left), next), dir, map) {
        Ok(new_map) -> #(next, new_map)
        Error(_) -> #(robot, map)
      }
    x -> {
      io.debug(#(x, dir))
      panic
    }
  }
}

fn debug(m: utils.Map) {
  let bounds = #(50, 50 * 2)

  list.range(0, bounds.0 - 1)
  |> list.map(fn(y) {
    list.range(0, bounds.1 - 1)
    |> list.map(fn(x) {
      case dict.get(m, #(y, x)) {
        Ok(x) -> x
        Error(_) -> "."
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> string.append("\n")
  |> io.println

  process.sleep(50)
}

fn dir_to_str(dir: Direction) -> String {
  case dir {
    Up -> "^"
    Down -> "v"
    Left -> "<"
    Right -> ">"
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
      io.println("Next: " |> string.append(dir_to_str(dir)))
      debug(dict.insert(map, robot, "@"))
      move(robot, dir, map)
    })

  final_map
  |> dict.to_list
  |> list.filter(fn(x) { x.1 == "[" })
  |> list.map(pair.first)
  |> list.map(fn(x) { x.0 * 100 + x.1 })
  |> int.sum
  |> io.debug
}
