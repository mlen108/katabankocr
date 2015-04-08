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
        " _  _  _  _  _  _  _  _  _ \n" +
        "| || || || || || || || || |\n" +
        "|_||_||_||_||_||_||_||_||_|\n" +
        "\n"

        BankOCR.new.parse(new_data)
      end

      it { expect(subject[0]).to eql('000000000') }
    end

    context 'should parse the entries from file' do
      it { expect(subject.parse[1]).to eql('111111111') }
    end
  end
end
