import day03/part1.{match}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/utils

const filepath = "./src/day03/input.txt"

fn preprocess(str: String) {
  case string.split_once(str, on: "don't()") {
    Ok(#(head, tail)) -> {
      case string.split_once(tail, on: "do()") {
        Ok(#(_, tail_tail)) -> string.append(head, preprocess(tail_tail))
        Error(_) -> head
      }
    }
    Error(_) -> str
  }
}

pub fn main() {
  filepath
  |> utils.file_to_lines
  |> string.concat
  |> preprocess
  |> io.debug
  |> match
  |> list.map(fn(numbers) {
    case numbers {
      [a, b] -> a * b
      _ -> panic
    }
  })
  |> int.sum
  |> int.to_string
  |> io.println
}
