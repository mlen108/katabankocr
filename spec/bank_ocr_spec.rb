require 'bank_ocr'

describe BankOCR do
  describe '.exists?' do
    context 'when the file exists' do
      it { expect(subject.exists?).to be true }
    end

    context 'when the file does not exist' do
      subject { BankOCR.new('non_existing_file.txt') }

      it { expect(subject.exists?).to be false }
    end
  end

  describe '.read' do
    context 'when the file is not empty' do
      it { expect(subject.read).not_to be_empty}
    end

    context 'when the file does not exist' do
      subject { BankOCR.new('missing_file.txt') }

      it { expect(subject.read).to be nil}
    end

    context 'when the file has right content' do
      it { expect(subject.read).to include ' _  _  _  _  _  _  _  _  _ ' }
    end
  end

  describe '.parse' do
    context 'should parse the entries from string' do
      subject do
        new_data =
        " _  _  _  _  _  _  _  _    \n" +
        "| || || || || || || || |  |\n" +
        "|_||_||_||_||_||_||_||_|  |\n" +
        "\n"

        BankOCR.new.parse(new_data)
      end

      it { expect(subject[0]).to eq('000000001') }
    end

    context 'should parse the entries from file' do
      it { expect(subject.parse[1]).to eq('111111111') }
    end
  end
end

describe AccountEntry do
  describe '.parse' do
    context 'when the account entry is empty' do
      subject do
        empty_entry =
        ["\n"] +
        ["\n"] +
        ["\n"] +
        ["\n"]

        AccountEntry.new.parse(empty_entry)
      end

      it { expect(subject).to be nil }
    end

    context 'when the account entry is valid' do
      subject do
        invalid_entry =
        ["    _  _     _     _  _    \n"] +
        ["  | _| _||_|| |  | _| _||_|\n"] +
        ["  ||_  _|  ||_|  ||_  _|  |\n"] +
        ["\n"]

        AccountEntry.new.parse(invalid_entry)
      end

      it { expect(subject).to eq('123401234') }
    end
  end
end

describe AccountNumber do
  describe '.initialize' do
    context 'when the account number is of integer type' do
      subject { AccountNumber.new(123456789) }

      it { expect(subject.account_number).to be_instance_of(String) }
    end

    context 'when the account number is of string type' do
      subject { AccountNumber.new('123456789') }

      it { expect(subject.account_number).to be_instance_of(String) }
    end
  end

  describe '.to_s' do
    context 'when the account number is legible' do
      subject { AccountNumber.new(123456789) }

      it { expect(subject.to_s).to eq('123456789') }
    end

    context 'when the account number has wrong checksum' do
      subject { AccountNumber.new(664371495) }

      it { expect(subject.to_s).to eq('664371495 ERR') }
    end

    context 'when the account number is illegible' do
      subject { AccountNumber.new('86110??36') }

      it { expect(subject.to_s).to eq('86110??36 ILL') }
    end
  end

  describe '.checksum' do
    context 'when the account number has valid checksum' do
      subject { AccountNumber.new(000000000) }

      it { expect(subject.checksum).to eq(0) }
    end
  end

  describe '.valid?' do
    context 'when the account number is valid' do
      subject { AccountNumber.new(457508000) }

      it { expect(subject.valid?).to be true }
    end
  end

  describe '.invalid?' do
    context 'when the account number is invalid' do
      subject { AccountNumber.new(664371495) }

      it { expect(subject.invalid?).to be true }
    end
  end

  describe '.illegible?' do
    context 'when the number is illegible' do
      subject { AccountNumber.new('12345678?') }

      it { expect(subject.illegible?).to be true }
    end
  end
end
