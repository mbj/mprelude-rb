# frozen_string_literal: true

RSpec.describe MPrelude::Maybe::Nothing do
  subject { described_class.new }

  let(:block) { -> {} }

  describe '#fmap' do
    def apply
      subject.fmap(&block)
    end

    include_examples 'no block evaluation'
    include_examples 'requires block'
    include_examples 'returns self'
  end

  describe '#bind' do
    def apply
      subject.bind(&block)
    end

    include_examples 'no block evaluation'
    include_examples 'requires block'
    include_examples 'returns self'
  end
end

RSpec.describe MPrelude::Maybe::Just do
  subject { described_class.new(value) }

  let(:block_result) { instance_double(Object, 'block result') }
  let(:value)        { instance_double(Object, 'value')        }
  let(:yields)       { []                                      }

  let(:block) do
    lambda do |value|
      yields << value
      block_result
    end
  end

  describe '#fmap' do
    def apply
      subject.fmap(&block)
    end

    include_examples 'requires block'
    include_examples 'Functor#fmap block evaluation'
  end

  describe '#bind' do
    def apply
      subject.bind(&block)
    end

    include_examples 'requires block'
    include_examples '#bind block evaluation'
  end
end
