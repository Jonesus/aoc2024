import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/utils
import rememo/memo
import simplifile

const filepath = "./src/day11/input.txt"

fn blink(current: #(Int, Int), cache) -> Int {
  use <- memo.memoize(cache, current)
  let #(stone, blinks) = current

  case blinks {
    75 -> 1
    _ -> {
      let stone_string = stone |> int.to_string
      let stone_string_length = string.length(stone_string)
      let even = stone_string_length % 2 == 0
      case stone {
        0 -> blink(#(1, blinks + 1), cache)
        _ if even -> {
          let assert Ok(start) =
            string.drop_end(stone_string, stone_string_length / 2) |> int.parse
          let assert Ok(end) =
            string.drop_start(stone_string, stone_string_length / 2)
            |> int.parse
          blink(#(start, blinks + 1), cache) + blink(#(end, blinks + 1), cache)
        }
        x -> blink(#(x * 2024, blinks + 1), cache)
      }
    }
  }
}

pub fn main() {
  use cache <- memo.create()

  let assert Ok(contents) = simplifile.read(filepath)

  contents
  |> utils.string_to_ints
  |> list.map(fn(x) { blink(#(x, 0), cache) })
  |> int.sum
  |> io.debug
}
