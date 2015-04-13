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
    end
  end

  describe Entry do
    context 'when the entry is empty' do
      subject do
        empty_entry =
        ["\n"] +
        ["\n"] +
        ["\n"] +
        ["\n"]

        described_class.new(empty_entry)
      end

      it 'will be nil' do
        expect(subject.account_number).to be nil
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

      it 'will have some checksum value' do
        expect(subject.checksum).to eq(0)
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
        expect(subject.valid?).to be false
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

      it 'will have some checksum value' do
        expect(subject.checksum).to eq(93)
      end

      it 'will have not valid checksum' do
        expect(subject.valid?).to be false
      end

      it 'will contain illegible character' do
        expect(subject.illegible?).to be true
      end
    end
  end

  describe Reader do
    context 'when parsing use case 1' do
      subject { Reader.new('data/use_case_1.ocr') }

      it 'will have correct numbers' do
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

      it 'will have correct numbers' do
        numbers = [
          '000000051',
          '1234?678? ILL',
          '49006771? ILL'
        ]
        expect(subject.parse).to match_array(numbers)
      end
    end
  end
end
