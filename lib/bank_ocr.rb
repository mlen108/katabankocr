DIGITS = {
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

module OCR
  class Reader
    attr_reader :data

    def initialize(file_path)
      unless File.exists?(file_path)
        fail "File '#{file_path}' not found."
      end

      @data = File.read(file_path)
    end

    def parse
      entries = []

      # split data every 4 lines as each entry is represented in 4 lines blocks.
      data.lines.each_slice(4) do |entry|
        entries << Entry.new.parse(entry).to_s
      end

      entries
    end
  end

  class Entry
    attr_reader :digits

    def initialize
      @digits = nil
    end

    def to_s
      @digits
    end

    def parse(entry)
      return unless entry.inject(:+).size == 85

      output = []
      # each line has 27 chars & each digit is represented as 3 chars long
      # so iterate these numbers and substring at correct step(s).
      (0..24).step(3) do |idx|
        digit = entry[0][idx, 3] << entry[1][idx, 3] << entry[2][idx, 3]
        # find digit representation within our hash map.
        if DIGITS.include?(digit)
          output << DIGITS[digit]
        else
          output << '?'
        end
      end

      @digits = output.join
    end
  end

  class Digit
    attr_reader :account_number

    def initialize(account_number)
      if account_number.is_a?(Integer)
        account_number = account_number.to_s
      end

      @account_number = account_number
    end

    def to_s
      if illegible?
        "#{account_number} ILL"
      elsif invalid?
        "#{account_number} ERR"
      else
        "#{account_number}"
      end
    end

    def checksum
      (0..account_number.length).reduce(0) do |sum, idx|
        sum += account_number[idx * -1].to_i * idx
      end
    end

    def valid?
      checksum % 11 == 0
    end

    def invalid?
      !valid?
    end

    def illegible?
      account_number.include?('?')
    end
  end
end
