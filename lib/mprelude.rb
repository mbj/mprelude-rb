# frozen_string_literal: true

require 'abstract_type'
require 'adamantium'
require 'concord'

module MPrelude
  module RequireBlock
    include AbstractType

  private

    # Raise error unless block is given
    #
    # @yield [] the block required by callers
    #
    # @yieldreturn [void]
    #
    # @return [self]
    #
    # @api private
    def require_block
      fail LocalJumpError unless block_given?
      self
    end
  end # RequireBLock

  class Maybe
    include(
      AbstractType,
      Adamantium::Flat,
      RequireBlock
    )

    class Nothing < self
      instance = new

      define_method(:new) { instance }

      # Evaluate Functor block
      #
      # @example
      #   Maybe::Nothing.new.fmap { log('got nothing') }
      #
      # @yield [] the required block to perform side effects if needed
      #
      # @yieldreturn [void]
      #
      # @return [self]
      #
      # @api public
      def fmap(&block)
        require_block(&block)
      end

      # Evaluate applicative block
      #
      # @example
      #   Maybe::Nothing.new.apply { log('got nothing') }
      #
      # @yield [] the required block to perform side effects if needed
      #
      # @yieldreturn [void]
      #
      # @return [self]
      #
      # @api public
      def apply(&block)
        require_block(&block)
      end
    end # Nothing

    class Just < self
      include Concord.new(:value)

      # Evaluate Functor block
      #
      # @example
      #   f = ->(a) { a.succ }
      #   MPrelude::Maybe::Just.new(1).fmap(&f)
      #   #=> MPrelude::Maybe::Just.new(2)
      #
      # @yield [value]
      #   the function to be applied over value
      #
      # @yieldparam [Object] value
      #   the value inside the Just
      #
      # @yieldreturn [Object]
      #   the value to be lifted into Just
      #
      # @return [Just]
      #   the function application result lifted into Just
      #
      # @api public
      def fmap
        Just.new(yield(value))
      end

      # Evaluate applicative block
      #
      # @example
      #   g = ->(a) { a.succ }
      #   f = MPrelude::Maybe::Just.public_method(:new)
      #   h = ->(a) { f.call(g.call(a)) }
      #   MPrelude::Maybe::Just.new(1).apply(&h)
      #   #=> MPrelude::Maybe::Just.new(2)
      #
      # @yield [value]
      #   a function lifting the transformed value to Just
      #
      # @yieldparam [Object] value
      #   the value inside the receiving Just instance
      #
      # @yieldreturn [Just<Object>]
      #   the function result lifted into Just
      #
      # @return [Just<Object>]
      #
      # @api public
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
      RequireBlock
    )

    # Lift block return value to Right or raised error to Left
    #
    # @overload wrap_error(exception)
    #   Wrap a single class of exceptions
    #   @param [Class<Exception>] exception
    #
    # @overload wrap_error(exception, *)
    #   Wrap multiple classes of exceptions
    #   @param [Class<Exception>] exception
    #     the class of exceptions to wrap
    #   @param [Class<Exception>] *
    #     more classes of exceptions to wrap
    #
    # @yield []
    #   a block returning a value to lift to Right or raising an exception
    #
    # @yieldreturn [Object]
    #   the value to lift to Right
    #
    # @raise [Exception]
    #   when block raised an exception not inheriting from any wrapped class
    #
    # @return [Either]
    #   the exception lifted to Left or the block result lifted to Right
    #
    # @api public
    def self.wrap_error(*exceptions)
      Right.new(yield)
    rescue *exceptions => error
      Left.new(error)
    end

    # Test for left constructor
    #
    # @return [Boolean]
    def left?
      instance_of?(Left)
    end

    # Test for right constructor
    #
    # @return [Boolean]
    def right?
      instance_of?(Right)
    end

    class Left < self
      # Evaluate functor block
      #
      # @yield [] the required block to perform side effects on Left
      #
      # @yieldreturn [void]
      #
      # @return [self]
      def fmap(&block)
        require_block(&block)
      end

      # Evaluate applicative block
      #
      # @yield [] the required block to perform side effects on Left
      #
      # @yieldreturn [void]
      #
      # @return [self]
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
      # @yield [value] if a block is given
      #
      # @yieldparam [Object] value
      #   the Left value useful for computing a default value
      #
      # @yieldreturn [Object]
      #   the computed default value
      #
      # @return [Object]
      #   the value returned from the block
      #
      # @raise [RuntimeError]
      #   if no block is given
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

fun  = ->(a) { a.succ }                            # fun   :: a             -> a
pure = Maybe::Just.public_method(:new)             # pure  :: a             -> Just a
h    = ->(f, g, a) { f.call(g.call(a)) }           # h     :: (a -> Just a) -> (a -> a)                              -> Just a
Maybe::Just.new(1).apply(&h.curry.call(pure, fun)) # apply :: Just a        -> ((a -> Just a) -> (a -> a) -> Just a) -> Just a
                                                   #              ^
                                                   #           receiver


g = ->(a) { a.succ }
f = Maybe::Just.public_method(:new)
h = ->(a) { f.call(g.call(a)) }
Maybe::Just.new(1).apply(&h)
