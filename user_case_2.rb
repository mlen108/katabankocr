# define the digits as 3x3 cells on 3 lines to improve readability.
VALUES = {
  " _ " +
  "| |" +
  "|_|" => 0,

  "   " +
  "  |" +
  "  |" => 1,

  " _ " +
  " _|" +
  "|_ " => 2,

  " _ " +
  " _|" +
  " _|" => 3,

  "   " +
  "|_|" +
  "  |" => 4,

  " _ " +
  "|_ " +
  " _|" => 5,

  " _ " +
  "|_ " +
  "|_|" => 6,

  " _ " +
  "  |" +
  "  |" => 7,

  " _ " +
  "|_|" +
  "|_|" => 8,

  " _ " +
  "|_|" +
  " _|" => 9
}

def read_file(path = './data_entries.txt')
  file = File.open(path, 'r')
  data = file.read
  file.close

  return data
end

def generate(data = nil)
  if data.nil?
    data = read_file()
  end

  accounts = []
  # split data every 4 lines as each entry is represented in 4 lines blocks.
  data.lines.each_slice(4) do |entry|
    accounts << parse(entry).join
  end

  return accounts
end

# parses entry to find account number.
def parse(entry)
  output = []
  # each line has 27 chars & each digit is represented as 3 chars long
  # so iterate these numbers and substring at correct step(s).
  (0..24).step(3) do |idx|
    digit = entry[0][idx, 3] << entry[1][idx, 3] << entry[2][idx, 3]
    # find digit representation within our hash map.
    output << VALUES[digit]
  end
  return output
end

# calculate account number's checksum and return its result
# checksum calculation: (d1+2*d2+3*d3 +..+9*d9) mod 11
def checksum(account_number)
  sum = 0
  # TODO: invalid checksum for wrong values.. :(
  (0..account_number.length).reduce(0) do |idx|
    sum += account_number[idx * -1].to_i * idx
  end
  return sum % 11
end

items = generate()
items.each do |item|
  puts checksum(item)
end
