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

# split data every 4 lines as each entry is represented in 4 lines.
data.lines.each_slice(4) do |s|
  digits = []
  (0..24).step(3) do |n|
    out = ""
    out << s[0].to_s[n, 3]
    out << s[1].to_s[n, 3]
    out << s[2].to_s[n, 3]
    digits << VALUES[out]
  end
  puts digits.join
end
