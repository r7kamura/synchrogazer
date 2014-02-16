module Synchrogazer
  class Observable < Enumerator::Lazy
    def self.from(enumerable)
      new do |yielder|
        enumerable.each do |element|
          yielder << element
        end
      end
    end

    def self.just(value)
      from([value])
    end

    def initialize(&block)
      @block = block
    end

    def each(&block)
      enumerator.each(&block)
    end

    def on_completed(&block)
      @block_on_completed = block
      self
    end

    def on_error(&block)
      @block_on_error = block
      self
    end

    private

    def enumerator
      @enumerator ||= Enumerator.new do |yielder|
        with_callback do
          instance_exec(yielder, &@block)
        end
      end
    end

    def block_on_completed
      @block_on_completed ||= -> {}
    end

    def block_on_error
      @block_on_error ||= ->(exception) { raise exception }
    end

    def completed
      block_on_completed.call
    end

    def raised(exception)
      block_on_error.call(exception)
    end

    def with_callback(&block)
      block.call
      completed
    rescue => exception
      raised(exception)
    end
  end
end
