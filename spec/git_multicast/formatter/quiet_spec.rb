module GitMulticast
  class Formatter
    describe Quiet do
      subject(:formatter) { described_class.new }

      let(:name) { 'some action' }
      let(:status) { 0 }
      let(:result_string) { 'stuff to be done' }

      let(:result) { Task::Result.new(name, result_string, status) }

      describe '#format' do
        subject(:format) { formatter.format(result) }

        it do
          is_expected.to match(/^$/)
        end

        context 'when exit_status is not 0' do
          let(:status) { 999 }

          it do
            is_expected.to match(/\[Error\]/)
              .and match(/#{result}/)
          end
        end
      end
    end
  end
end
