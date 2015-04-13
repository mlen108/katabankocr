require 'bank_ocr'

module OCR
  describe Reader do
    describe '.exists?' do
      context 'when the file exists' do
        it { expect(subject.exists?).to be true }
      end

      context 'when the file does not exist' do
        subject { described_class.new('non_existing_file.txt') }

        it { expect(subject.exists?).to be false }
      end
    end

    describe '.read' do
      context 'when the file is not empty' do
        it { expect(subject.read).not_to be_empty}
      end

      context 'when the file does not exist' do
        subject { described_class.new('missing_file.txt') }

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

          described_class.new.parse(new_data)
        end

        it { expect(subject).to match_array(['000000001']) }
      end

      context 'when parses the entries from file' do
        it 'should contain exact items' do
          items = [
            '000000000',
            '111111111',
            '123456789',
            '222222222',
            '333333333',
            '444444444',
            '555555555',
            '666666666',
            '777777777',
            '888888888',
            '999999999'
          ]
          expect(subject.parse).to match_array(items)
        end
      end
    end
  end

  describe Entry do
    describe '.parse' do
      context 'when the account entry is empty' do
        subject do
          empty_entry =
          ["\n"] +
          ["\n"] +
          ["\n"] +
          ["\n"]

          described_class.new.parse(empty_entry)
        end

        it { expect(subject).to be nil }
      end

      context 'when the account entry is valid' do
        subject do
          valid_entry =
          ["    _  _     _     _  _    \n"] +
          ["  | _| _||_|| |  | _| _||_|\n"] +
          ["  ||_  _|  ||_|  ||_  _|  |\n"] +
          ["\n"]

          described_class.new.parse(valid_entry)
        end

        it { expect(subject).to eq('123401234') }
      end

      context 'when the account entry is invalid' do
        subject do
          invalid_entry =
          [" _  _     _     _  _  #    \n"] +
          [" _| _||_|| |  | _| _||#|  |\n"] +
          ["|_  _|  ||_|  ||_  _| #|  |\n"] +
          ["\n"]

          described_class.new.parse(invalid_entry)
        end

        it { expect(subject).to eq('2340123?1') }
      end
    end
  end

  describe Digit do
    describe '.initialize' do
      context 'when the account number is of integer type' do
        subject { described_class.new(123456789) }

        it { expect(subject.account_number).to be_instance_of(String) }
      end

      context 'when the account number is of string type' do
        subject { described_class.new('123456789') }

        it { expect(subject.account_number).to be_instance_of(String) }
      end
    end

    describe '.to_s' do
      context 'when the account number is legible' do
        subject { described_class.new(123456789) }

        it { expect(subject.to_s).to eq('123456789') }
      end

      context 'when the account number has wrong checksum' do
        subject { described_class.new(664371495) }

        it { expect(subject.to_s).to eq('664371495 ERR') }
      end

      context 'when the account number is illegible' do
        subject { described_class.new('86110??36') }

        it { expect(subject.to_s).to eq('86110??36 ILL') }
      end
    end

    describe '.checksum' do
      context 'when the account number has valid checksum' do
        subject { described_class.new(000000000) }

        it { expect(subject.checksum).to eq(0) }
      end
    end

    describe '.valid?' do
      context 'when the account number is valid' do
        subject { described_class.new(711111111) }

        it { expect(subject.valid?).to be true }
      end
    end

    describe '.invalid?' do
      context 'when the account number is invalid' do
        subject { described_class.new(664371495) }

        it { expect(subject.invalid?).to be true }
      end
    end

    describe '.illegible?' do
      context 'when the number is illegible' do
        subject { described_class.new('12345678?') }

        it { expect(subject.illegible?).to be true }
      end
    end
  end
end
