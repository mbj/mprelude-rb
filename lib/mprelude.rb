# frozen_string_literal: true

require 'abstract_type'
require 'adamantium'
require 'concord'

module MPrelude
  module Functor
    include AbstractType

    abstract_method :fmap

  private

    # Raise error unless block is provided
    #
    # @raise [MissingBlockError]
    #   if no block is given
    #
    # @return [self]
    def require_block
      fail LocalJumpError unless block_given?
      self
    end
  end # Functor

  class Maybe
    include(
      AbstractType,
      Adamantium::Flat,
      Functor
    )

    class Nothing < self
      instance = new

      define_method(:new) { instance }

      # Evaluate functor block
      #
      # @return [Maybe::Nothing]
      def fmap(&block)
        require_block(&block)
      end

      # Evaluate applicative block
      #
      # @return [Maybe::Nothing]
      def apply(&block)
        require_block(&block)
      end
    end # Nothing

    class Just < self
      include Concord.new(:value)

      # Evalute functor block
      #
      # @return [Maybe::Just<Object>]
      def fmap
        Just.new(yield(value))
      end

      # Evalute applicative block
      #
      # @return [Maybe]
      def apply
        yield(value)
      end
    end # Just
  end # Maybe

  class Either
    include(
      AbstractType,
      Adamantium::Flat,
      Concord.new(:value),
      Functor
    )

    # Execute block and wrap error in left
    #
    # @param [Class:Exception] error
    #
    # @return [Either<Exception, Object>]
    def self.wrap_error(error)
      Right.new(yield)
    rescue error => exception
      Left.new(exception)
    end

    class Left < self
      # Evaluate functor block
      #
      # @return [Either::Left<Object>]
      def fmap(&block)
        require_block(&block)
      end

      # Evaluate applicative block
      #
      # @return [Either::Left<Object>]
      def apply(&block)
        require_block(&block)
      end

      # Unwrap value from left
      #
      # @return [Object]
      def from_left
        value
      end

      # Unwrap value from right
      #
      # @return [Object]
      #
      # rubocop:disable Style/GuardClause
      def from_right
        if block_given?
          yield(value)
        else
          fail "Expected right value, got #{inspect}"
        end
      end
      # rubocop:enable Style/GuardClause

      # Map over left value
      #
      # @return [Either::Right<Object>]
      def lmap
        Left.new(yield(value))
      end

      # Evaluate left side of branch
      #
      # @param [#call] left
      # @param [#call] _right
      def either(left, _right)
        left.call(value)
      end
    end # Left

    class Right < self
      # Evaluate functor block
      #
      # @return [Either::Right<Object>]
      def fmap
        Right.new(yield(value))
      end

      # Evaluate applicative block
      #
      # @return [Either<Object>]
      def apply
        yield(value)
      end

      # Unwrap value from left
      #
      # @return [Object]
      #
      # rubocop:disable Style/GuardClause
      def from_left
        if block_given?
          yield(value)
        else
          fail "Expected left value, got #{inspect}"
        end
      end
      # rubocop:enable Style/GuardClause

      # Unwrap value from right
      #
      # @return [Object]
      def from_right
        value
      end

      # Map over left value
      #
      # @return [Either::Right<Object>]
      def lmap(&block)
        require_block(&block)
      end

      # Evaluate right side of branch
      #
      # @param [#call] _left
      # @param [#call] right
      def either(_left, right)
        right.call(value)
      end
    end # Right
  end # Either
end # MPrelude
