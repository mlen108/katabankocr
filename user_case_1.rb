file = File.open('./user_case_1_data.txt', 'r')
data = file.read
file.close

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

# split data every 4 lines as each entry is represented in 4 lines blocks.
data.lines.each_slice(4) do |entry|
  output = []
  # each line has 27 chars & each digit is represented as 3 chars long
  # so iterate these numbers and substring at correct step(s).
  (0..24).step(3) do |idx|
    digit = entry[0][idx, 3] << entry[1][idx, 3] << entry[2][idx, 3]
    # find digit representation within our hash map.
    output << VALUES[digit]
  end
  puts output.join
end
