require 'spec_helper'
require 'bank_ocr'

module OCR
  describe Reader do
    context 'when the file does not exist' do
      it 'will raise an error' do
        expect{ described_class.new('not_existing_file') }.to raise_error
      end
    end

    context 'when the file exists' do
      subject { Reader.new('data/use_case_1.ocr') }

      it 'will not raise an error' do
        expect{ described_class.new('data/use_case_1.ocr') }.not_to raise_error
      end

      it 'will be instance of a correct class' do
        expect(subject).to be_instance_of(described_class)
      end

      it 'will be not empty' do
        expect(subject.data).not_to be_empty
      end

      it 'will contain data' do
        expect(subject.data).to include(' _  _  _  _  _  _  _  _  _ ')
      end

      it 'will return numbers for parsed entries' do
        expect(subject.parse.at(0)).to eq('000000000')
      end

      it 'will return alternative numbers for parsed entries' do
        expect(subject.parse_alternatives.at(0)).to eq('000000000')
      end
    end
  end

  describe Entry do
    context 'when the entry has invalid length' do
      it 'will raise an error' do
        expect { described_class.new(["#"]) }.to raise_error
      end
    end

    context 'when the entry is valid' do
      subject do
        valid_entry =
        [" _  _  _  _  _  _  _  _  _ \n"] +
        ["| || || || || || || || || |\n"] +
        ["|_||_||_||_||_||_||_||_||_|\n"] +
        ["\n"]

        described_class.new(valid_entry)
      end

      it 'will be equal to correct number' do
        expect(subject.to_s).to eq('000000000')
      end

      it 'will have valid checksum' do
        expect(subject.valid?).to be true
      end

      it 'will contain legible characters only' do
        expect(subject.illegible?).to be false
      end
    end

    context 'when the entry has wrong checksum' do
      subject do
        bad_checksum =
        [" _  _     _     _  _       \n"] +
        [" _| _||_|| |  | _| _||_|  |\n"] +
        ["|_  _|  ||_|  ||_  _|  |  |\n"] +
        ["\n"]

        described_class.new(bad_checksum)
      end

      it 'will not be valid' do
        expect(subject.invalid?).to be true
      end
    end

    context 'when the entry contains illegal character' do
      subject do
        illegal_entry =
        [" _  _     _     _  _  #    \n"] +
        [" _| _||_|| |  | _| _||#|  |\n"] +
        ["|_  _|  ||_|  ||_  _| #|  |\n"] +
        ["\n"]

        described_class.new(illegal_entry)
      end

      it 'will replace illegal characters' do
        expect(subject.to_s).to eq('2340123?1 ILL')
        expect(subject.to_s).to include('?')
      end

      it 'will have not valid checksum' do
        expect(subject.valid?).to be false
      end

      it 'will contain illegible character' do
        expect(subject.illegible?).to be true
      end
    end
  end

  describe EntryAlternative do
    context 'when the entry is valid' do
      subject do
        valid_entry =
        [" _  _  _  _  _  _  _  _  _ \n"] +
        ["| || || || || || || || || |\n"] +
        ["|_||_||_||_||_||_||_||_||_|\n"] +
        ["\n"]

        described_class.new(valid_entry)
      end

      it 'will be equal to correct number' do
        expect(subject.to_s).to eq('000000000')
      end
    end

    context 'when the entry contains illegal character' do
      subject do
        illegal_entry =
        [" _  _     _     _  _  #    \n"] +
        [" _| _||_|| |  | _| _||#|  |\n"] +
        ["|_  _|  ||_|  ||_  _| #|  |\n"] +
        ["\n"]

        described_class.new(illegal_entry)
      end

      it 'will replace illegal characters' do
        expect(subject.to_s).to eq('2340123?1 ILL')
        expect(subject.to_s).to include('?')
      end
    end
  end

  describe Reader do
    context 'when parsing use case 1' do
      subject { Reader.new('data/use_case_1.ocr') }

      it 'will contain these matches' do
        numbers = [
          '000000000',
          '111111111 ERR',
          '123456789',
          '222222222 ERR',
          '333333333 ERR',
          '444444444 ERR',
          '555555555 ERR',
          '666666666 ERR',
          '777777777 ERR',
          '888888888 ERR',
          '999999999 ERR'
        ]
        expect(subject.parse).to match_array(numbers)
      end
    end

    context 'when parsing use case 3' do
      subject { Reader.new('data/use_case_3.ocr') }

      it 'will contain these matches' do
        numbers = [
          '000000051',
          '1234?678? ILL',
          '49006771? ILL'
        ]
        expect(subject.parse).to match_array(numbers)
      end
    end

    context 'when parsing use case 4' do
      subject { Reader.new('data/use_case_4.ocr') }

      it 'will contain these matches' do
        numbers = [
          "711111111",
          "777777177",
          "200800000",
          "333393333",
          "888888888 AMB ['888886888', '888888880', '888888988']",
          "555555555 AMB ['555655555', '559555555']",
          "666666666 AMB ['666566666', '686666666']",
          "999999999 AMB ['899999999', '993999999', '999959999']",
          "490067715 AMB ['490067115', '490067719', '490867715']",
          "123456789",
          "000000051",
          "490867715"
        ]
        expect(subject.parse_alternatives).to match_array(numbers)
      end
    end
  end
end
