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

FROM_DIGITS = DIGITS.invert

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
      data.lines.each_slice(4).map { |e| Entry.new(e).to_s }
    end

    def parse_alternatives
      # returns AMB options for given account entry
      data.lines.each_slice(4).map { |e| EntryAlternative.new(e).to_s }
    end
  end

  class Entry
    attr_reader :entry
    attr_reader :account_number
    attr_reader :sth

    def initialize(entry)
      @entry = entry
      @account_number = []
      @account_chars = []

      check
      parse
    end

    def account_number
      @account_number.join
    end

    def to_s
      if valid?
        "#{account_number}"
      elsif illegible?
        "#{account_number} ILL"
      else
        "#{account_number} ERR"
      end
    end

    def check
      unless entry.inject(:+).size == 85
        fail "Entry has wrong length."
      end
    end

    def parse
      # each line has 27 chars & each digit is represented as 3 chars long
      # so iterate these numbers and substring at correct step(s).
      (0..24).step(3) do |idx|
        digit = entry[0][idx, 3] << entry[1][idx, 3] << entry[2][idx, 3]

        @account_number << Digit.new.lookup(digit)
        # keep 'raw' char for future comparison
        @account_chars << digit
      end
    end

    def valid?
      Number.new(@account_number).valid?
    end

    def illegible?
      Number.new(@account_number).illegible?
    end

    def recognize(characters)
      characters.map { |ch| Digit.new.lookup(ch) }.join
    end

    def find_alternatives
      result = []
      prefix = []
      dup_entry = @account_chars.dup

      # find all possible combinations by comparing each character
      # within given entry with each character stored in hash map
      while !dup_entry.empty?
        ch = dup_entry.shift
        Digit.new.guess(ch).each do |guess|
          digits = recognize(prefix) + guess.to_s + recognize(dup_entry)
          result << digits unless Number.new(digits).illegible?
        end
        prefix << ch
      end

      result
    end

    def valid_alternatives
      # return checksum valid numbers
      find_alternatives.select { |digits| Number.new(digits).valid? }.sort
    end
  end

  class EntryAlternative < Entry
    # extend the parent' method to keep UserCase1 happy
    def to_s
      if valid?
        "#{account_number}"
      else
        choices = valid_alternatives
        if choices.size == 1
          "#{choices.first}"
        elsif choices.size > 1
          "#{account_number} AMB [" + choices.map { |c| "'#{c}'" }.join(', ') + "]"
        elsif illegible?
          "#{account_number} ILL"
        else
          "#{account_number} ERR"
        end
      end
    end
  end

  class Number
    attr_reader :account_number

    def initialize(account_number)
      @account_number = account_number
    end

    def checksum
      (0..account_number.length).reduce(0) do |sum, idx|
        sum += account_number[idx * -1].to_i * idx
      end
    end

    def valid?
      ! illegible? && account_number.length == 9 && checksum % 11 == 0
    end

    def invalid?
      ! valid?
    end

    def illegible?
      account_number.include?('?')
    end
  end

  class Digit
    def guess(character)
      FROM_DIGITS.map do |_, digit_repr|
        # count all the differences between original character & each matched one
        matches = character.chars.zip(digit_repr.chars).map { |a, b| a == b }.count(false)
        # only entries with one character changed are allowed
        if matches == 1
          DIGITS[digit_repr]
        end
      end
    end

    def lookup(character)
      DIGITS[character] || '?'
    end
  end
end
