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

class BankOCR
  attr_reader :path

  def initialize(path = 'data_entries.txt')
    @path = File.absolute_path(path)
  end

  def exists?
    File.exists?(path)
  end

  def read
    return unless exists?

    File.read(path)
  end

  def parse(data = nil)
    if data.nil?
      data = self.read
    end

    accounts = []
    # split data every 4 lines as each entry is represented in 4 lines blocks.
    data.lines.each_slice(4) do |entry|
      accounts << AccountEntry.new.parse(entry)
    end

    accounts
  end
end

class AccountEntry
  def parse(entry)
    output = []
    # each line has 27 chars & each digit is represented as 3 chars long
    # so iterate these numbers and substring at correct step(s).
    (0..24).step(3) do |idx|
      digit = entry[0][idx, 3] << entry[1][idx, 3] << entry[2][idx, 3]
      # find digit representation within our hash map.
      output << VALUES[digit]
    end

    output.join
  end
end
