import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/utils
import simplifile

const filepath = "./src/day11/input.txt"

fn blink(stone: Int, blinks: Int) -> Int {
  case blinks {
    25 -> 1
    _ -> {
      let stone_string = stone |> int.to_string
      let stone_string_length = string.length(stone_string)
      let even = stone_string_length % 2 == 0
      case stone {
        0 -> blink(1, blinks + 1)
        _ if even -> {
          let assert Ok(start) =
            string.drop_end(stone_string, stone_string_length / 2) |> int.parse
          let assert Ok(end) =
            string.drop_start(stone_string, stone_string_length / 2)
            |> int.parse
          blink(start, blinks + 1) + blink(end, blinks + 1)
        }
        x -> blink(x * 2024, blinks + 1)
      }
    }
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  contents
  |> utils.string_to_ints
  |> list.map(blink(_, 0))
  |> int.sum
  |> io.debug
}
