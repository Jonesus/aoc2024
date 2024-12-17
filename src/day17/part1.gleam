import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const filepath = "./src/day17/input.txt"

type Register {
  Register(a: Int, b: Int, c: Int)
}

fn parse_registers(rs: String) -> Register {
  let assert [a, b, c] =
    string.split(rs, "\n")
    |> list.map(string.split(_, ": "))
    |> list.map(fn(parts) {
      let assert [_, value_str] = parts
      let assert Ok(value) = int.parse(value_str)
      value
    })

  Register(a:, b:, c:)
}

fn parse_instructions(is: String) -> dict.Dict(Int, Int) {
  let assert [_, instruction_string] = string.split(is, ": ")
  string.split(instruction_string, ",")
  |> list.map(int.parse)
  |> result.values
  |> fn(ins) { list.zip(list.range(0, list.length(ins) - 1), ins) }
  |> dict.from_list
}

fn combo(operand: Int, register: Register) -> Int {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> register.a
    5 -> register.b
    6 -> register.c
    _ -> panic as { "Combo operand" <> int.to_string(operand) <> "is illegal." }
  }
}

fn adv(operand: Int, register: Register) -> Register {
  let numerator = int.to_float(register.a)
  let assert Ok(denominator) =
    int.power(2, int.to_float(combo(operand, register)))
  let result = numerator /. denominator

  Register(..register, a: float.truncate(result))
}

fn bxl(operand: Int, register: Register) -> Register {
  let result = int.bitwise_exclusive_or(register.b, operand)

  Register(..register, b: result)
}

fn bst(operand: Int, register: Register) -> Register {
  let result = combo(operand, register) % 8

  Register(..register, b: result)
}

fn jnz(operand: Int, register: Register) -> Result(Int, Nil) {
  case register.a {
    0 -> Error(Nil)
    _ -> Ok(operand)
  }
}

fn bxc(_: Int, register: Register) -> Register {
  let result = int.bitwise_exclusive_or(register.b, register.c)

  Register(..register, b: result)
}

fn out(operand: Int, register: Register) -> Int {
  let result = combo(operand, register) % 8

  result
}

fn bdv(operand: Int, register: Register) -> Register {
  let numerator = int.to_float(register.a)
  let assert Ok(denominator) =
    int.power(2, int.to_float(combo(operand, register)))
  let result = numerator /. denominator

  Register(..register, b: float.truncate(result))
}

fn cdv(operand: Int, register: Register) -> Register {
  let numerator = int.to_float(register.a)
  let assert Ok(denominator) =
    int.power(2, int.to_float(combo(operand, register)))
  let result = numerator /. denominator

  Register(..register, c: float.truncate(result))
}

fn tick(
  tape: dict.Dict(Int, Int),
  pointer: Int,
  register: Register,
) -> List(Int) {
  case dict.get(tape, pointer), dict.get(tape, pointer + 1) {
    Ok(0), Ok(operand) -> tick(tape, pointer + 2, adv(operand, register))
    Ok(1), Ok(operand) -> tick(tape, pointer + 2, bxl(operand, register))
    Ok(2), Ok(operand) -> tick(tape, pointer + 2, bst(operand, register))
    Ok(3), Ok(operand) -> {
      case jnz(operand, register) {
        Ok(new_pointer) -> tick(tape, new_pointer, register)
        Error(_) -> tick(tape, pointer + 2, register)
      }
    }
    Ok(4), Ok(operand) -> tick(tape, pointer + 2, bxc(operand, register))
    Ok(5), Ok(operand) -> [
      out(operand, register),
      ..tick(tape, pointer + 2, register)
    ]
    Ok(6), Ok(operand) -> tick(tape, pointer + 2, bdv(operand, register))
    Ok(7), Ok(operand) -> tick(tape, pointer + 2, cdv(operand, register))
    _, _ -> []
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read(filepath)

  let assert [registers_string, instructions_string] =
    string.split(contents, "\n\n")

  let register = parse_registers(registers_string)
  let tape = parse_instructions(instructions_string)

  tick(tape, 0, register)
  |> list.map(int.to_string)
  |> string.join(",")
  |> io.println
}
