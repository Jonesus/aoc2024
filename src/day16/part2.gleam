import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/set
import gleam/string
import lib/utils
import simplifile

const filepath = "./src/day16/input.txt"

type Direction {
  Up
  Down
  Left
  Right
}

type Reindeer =
  #(utils.Coordinate, Direction)

type ScoredReindeer =
  #(Reindeer, Int)

fn next_pos(pos: utils.Coordinate, dir: Direction) -> utils.Coordinate {
  case dir {
    Up -> #(pos.0 - 1, pos.1)
    Down -> #(pos.0 + 1, pos.1)
    Left -> #(pos.0, pos.1 - 1)
    Right -> #(pos.0, pos.1 + 1)
  }
}

fn rotate_clockwise(dir: Direction) -> Direction {
  case dir {
    Up -> Right
    Down -> Left
    Left -> Up
    Right -> Down
  }
}

fn rotate_anticlockwise(dir: Direction) -> Direction {
  case dir {
    Up -> Left
    Down -> Right
    Left -> Down
    Right -> Up
  }
}

fn parse_map(m: String) -> #(Reindeer, utils.Coordinate, set.Set(#(Int, Int))) {
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
        "S" -> [#(pos, "S"), ..acc]
        "E" -> [#(pos, "E"), ..acc]
        _ -> acc
      }
    })

  let assert Ok(#(#(start, _), coordinates)) =
    list.pop(entities, fn(e) {
      case e {
        #(_, "S") -> True
        _ -> False
      }
    })
  let assert Ok(#(#(end, _), rest)) =
    list.pop(coordinates, fn(e) {
      case e {
        #(_, "E") -> True
        _ -> False
      }
    })

  #(#(start, Right), end, rest |> list.map(pair.first) |> set.from_list)
}

fn next_positions(current: ScoredReindeer) {
  let #(#(pos, dir), score) = current

  let forward = #(#(next_pos(pos, dir), dir), score + 1)
  let cw = #(#(pos, rotate_clockwise(dir)), score + 1000)
  let acw = #(#(pos, rotate_anticlockwise(dir)), score + 1000)

  [forward, cw, acw]
}

fn dijkstra(
  current: ScoredReindeer,
  goal: utils.Coordinate,
  walls: set.Set(#(Int, Int)),
  visited: dict.Dict(Reindeer, Int),
) -> #(List(#(List(utils.Coordinate), Int)), dict.Dict(Reindeer, Int)) {
  let #(#(reindeer_pos, _), score) = current
  case reindeer_pos == goal {
    True -> #([#([reindeer_pos], score)], visited)
    False -> {
      next_positions(current)
      |> list.filter(fn(x) {
        let #(potential_reindeer, potential_score) = x
        case dict.get(visited, potential_reindeer), set.contains(walls, x.0.0) {
          Ok(score), False if score >= potential_score -> True
          Error(_), False -> True
          _, _ -> False
        }
      })
      |> list.fold(#([], visited), fn(acc, curr) {
        let #(old_paths, v) = acc
        let sorted_old_paths =
          old_paths
          |> list.sort(fn(a: #(List(#(Int, Int)), Int), b) {
            int.compare(a.1, b.1)
          })
        case sorted_old_paths {
          [best, ..] if best.1 < curr.1 -> #(old_paths, visited)
          _ -> {
            let #(finishes, new_v) =
              dijkstra(curr, goal, walls, dict.insert(v, curr.0, curr.1))
            let new_paths =
              finishes
              |> list.map(fn(success) {
                let #(path, score) = success
                #([reindeer_pos, ..path], score)
              })
            #(list.flatten([old_paths, new_paths]), new_v)
          }
        }
      })
    }
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  let #(start, end, walls) = parse_map(contents)

  let #(paths, _) =
    dijkstra(#(start, 0), end, walls, dict.from_list([#(start, 0)]))

  paths
  |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
  |> list.chunk(pair.second)
  |> list.take(1)
  |> list.flatten
  |> list.map(pair.first)
  |> list.flatten
  |> set.from_list
  |> set.size
  |> io.debug
}
