import gleam/deque
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const filepath = "./src/day09/input.txt"

fn compress_front(q: deque.Deque(Int)) -> List(Int) {
  case deque.pop_front(q) {
    Ok(#(-1, rest)) -> compress_back(rest)
    Ok(#(x, rest)) -> [x, ..compress_front(rest)]
    Error(_) -> []
  }
}

fn compress_back(q: deque.Deque(Int)) -> List(Int) {
  case deque.pop_back(q) {
    Ok(#(-1, rest)) -> compress_back(rest)
    Ok(#(x, rest)) -> [x, ..compress_front(rest)]
    Error(_) -> []
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  string.to_graphemes(contents)
  |> list.map(int.parse)
  |> result.values
  |> list.index_map(fn(x, i) {
    case i % 2 {
      0 -> list.repeat(i / 2, x)
      1 -> list.repeat(-1, x)
      _ -> panic
    }
  })
  |> list.flatten
  |> deque.from_list
  |> compress_front
  |> list.index_fold(0, fn(acc, item, index) { acc + item * index })
  |> io.debug
}
