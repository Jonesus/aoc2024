import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/set
import gleam/string
import gleamy/priority_queue
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

type Pq(a) =
  priority_queue.Queue(a)

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
  visited: set.Set(Reindeer),
  queue: Pq(ScoredReindeer),
) -> Result(Int, Nil) {
  let #(#(reindeer_pos, reindeer_dir), score) = current
  let v = set.insert(visited, #(reindeer_pos, reindeer_dir))
  case reindeer_pos == goal {
    True -> Ok(score)
    False -> {
      let q_next =
        next_positions(current)
        |> list.filter(fn(x) { set.contains(walls, x.0.0) |> bool.negate })
        |> list.fold(queue, fn(q, curr) {
          let #(reindeer, _) = curr
          case set.contains(v, reindeer) {
            True -> q
            False -> priority_queue.push(q, curr)
          }
        })

      case priority_queue.pop(q_next) {
        Error(_) -> Error(Nil)
        Ok(#(next, q_rest)) -> dijkstra(next, goal, walls, v, q_rest)
      }
    }
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  let #(start, end, walls) = parse_map(contents)

  dijkstra(
    #(start, 0),
    end,
    walls,
    set.new(),
    priority_queue.new(fn(a: ScoredReindeer, b: ScoredReindeer) {
      int.compare(a.1, b.1)
    }),
  )
  |> io.debug
}
