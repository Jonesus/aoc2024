import day06/part1
import gleam/otp/task
import gleam/set

import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import lib/utils

const filepath = "./src/day06/input.txt"

pub fn debug(map: utils.Map, g: part1.Guard) {
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
  visited: List(part1.Guard),
) -> List(part1.Guard) {
  let target_pos = part1.get_next_pos(g)
  case dict.get(map, target_pos) {
    Error(_) -> visited
    Ok("#") -> travel(map, part1.turn(g), visited)
    Ok(_) ->
      travel(map, part1.move_forward(g), [part1.move_forward(g), ..visited])
  }
}

fn check_loops(
  map: utils.Map,
  g: part1.Guard,
  visited: set.Set(part1.Guard),
) -> Bool {
  //debug(map, g)
  let target_pos = part1.get_next_pos(g)
  let again = set.contains(visited, part1.turn(g))
  case dict.get(map, target_pos) {
    Error(_) -> False
    Ok("O") if again -> True
    Ok("#") | Ok("O") -> {
      check_loops(map, part1.turn(g), set.insert(visited, part1.turn(g)))
    }
    Ok(_) -> {
      check_loops(
        map,
        part1.move_forward(g),
        set.insert(visited, part1.move_forward(g)),
      )
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

  let start_guard = #(start, part1.Up)

  let visited = travel(map, start_guard, [start_guard])

  let blocked_maps =
    visited
    |> list.map(pair.first)
    |> list.unique
    |> list.filter(fn(x) { x != start })
    |> list.map(fn(x) { dict.insert(map, x, "O") })

  blocked_maps
  |> list.reverse
  |> list.map(fn(x) {
    task.async(fn() {
      check_loops(x, start_guard, set.from_list([start_guard]))
    })
  })
  |> list.map(task.try_await(_, 1))
  |> list.filter(fn(x) {
    case x {
      Ok(res) -> res
      Error(_) -> True
    }
  })
  |> list.length
  |> int.to_string
  |> io.println
}
