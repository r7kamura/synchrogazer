require "spec_helper"

describe Synchrogazer::Observable do
  # Typical argument for .from
  let(:array) do
    [1, 2, 3]
  end

  # Typical argument for .just
  let(:value) do
    "a"
  end

  # Typical Observable object
  let(:observable) do
    described_class.from(array)
  end

  # Dummy Proc object to check if a passed block is called or not
  let(:block) do
    ->(*) {}.tap {|this| this.should_receive(:call) }
  end

  describe ".from" do
    context "with an Enumerable as 1st argument" do
      it "generates an Observable from given Enumerable" do
        described_class.from(array).should be_a described_class
      end

      it "generates an Enumerable object" do
        described_class.from(array).to_a.should == array
      end
    end
  end

  describe ".just" do
    context "with a value as 1st argument" do
      it "generates an Observable from given value" do
        described_class.just(value).should be_a described_class
      end

      it "generates an Enumerable object" do
        described_class.just(value).to_a.should == [value]
      end
    end
  end

  describe "#on_completed" do
    it "sets a callback invoked on completed" do
      observable.on_completed(&block).to_a
    end
  end

  describe "#on_error" do
    it "sets a callback invoked on error" do
      described_class.from(array).on_completed { raise }.on_error(&block).to_a
    end
  end

  describe "#initialize" do
    let(:observable) do
      described_class.new {|yielder| "this block should not be called" }
    end

    it "can be lazily evaluated by using Enumerable#lazy" do
      observable.take(2).should be_a Enumerator::Lazy
    end
  end

  describe "#each" do
    context "with no setting" do
      it "propagates an error raised inside" do
        expect { observable.on_completed { raise }.to_a }.to raise_error
      end
    end
  end
end
