import gleam/deque
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const filepath = "./src/day09/input.txt"

fn compress_front(q: deque.Deque(List(Int))) -> List(Int) {
  case deque.pop_front(q) {
    Ok(#([-1, ..lrest], qrest)) -> {
      let #(match, qrest, tail) =
        compress_back(qrest, list.length([-1, ..lrest]), [])

      list.flatten([
        match,
        compress_front(list.fold(tail, qrest, deque.push_back)),
      ])
    }
    Ok(#(x, qrest)) -> list.flatten([x, compress_front(qrest)])
    Error(_) -> []
  }
}

fn compress_back(
  q: deque.Deque(List(Int)),
  slot_length: Int,
  tail: List(List(Int)),
) -> #(List(Int), deque.Deque(List(Int)), List(List(Int))) {
  case deque.pop_back(q) {
    Ok(#([-1, ..lrest], qrest)) -> {
      compress_back(qrest, slot_length, [[-1, ..lrest], ..tail])
    }
    Ok(#(x, qrest)) -> {
      case list.length(x) {
        x_length if x_length == slot_length -> #(x, qrest, [
          list.repeat(-1, slot_length),
          ..tail
        ])
        x_length if x_length < slot_length -> #(
          x,
          qrest |> deque.push_front(list.repeat(-1, slot_length - x_length)),
          [list.repeat(-1, x_length), ..tail],
        )
        _ -> compress_back(qrest, slot_length, [x, ..tail])
      }
    }
    Error(_) -> #(list.repeat(-1, slot_length), deque.new(), tail)
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
  |> list.filter(fn(x) { list.length(x) > 0 })
  |> deque.from_list
  |> compress_front
  |> list.index_fold(0, fn(acc, item, index) {
    case item {
      -1 -> acc
      x -> acc + x * index
    }
  })
  |> io.debug
}
