class Object
  include Kernel

    # Begin private helper methods

    #  primitive_nobridge has max of 3 normal args, 1 star arg, 1 block arg
    #  example with a block argument
    #    primitive_nobridge '_foo*&' , '_foo:a:b:c:d:e:'
    #  example without a block argument
    #    primitive_nobridge '_foo*' , '_foo:a:b:c:d:'

    #  installed by RubyContext>>installPrimitiveBootstrap :
    #    primitive_nobridge 'class', 'class' # installed in Object

    #  Reimplementation of the following special selectors is disallowed
    #  by the parser and they are optimized by code generator to special bytecodes.
    #  Attempts to reimplement them will cause compile-time errors.
    # _isArray    # smalltalk   _isArray
    # _isBlock    # smalltalk   _isExecBlock
    # _isFixnum   # smalltalk   _isSmallInteger
    # _isFloat    # smalltalk   _isFloat
    # _isHash     # smalltalk   _isRubyHash
    # _isInteger  # smalltalk  _isInteger
    # _isNumeric  # smalltalk   _isNumber
    # _isRegexp   # smalltalk   _isRegexp
    # _isRange    # smalltalk   _isRange
    # _isString   # smalltalk   _isRubyString  # returns false for Symbols
    # _isSymbol   # smalltalk   _isSymbol      # returns false for Strings
    # _isStringOrSymbol # smalltalk _isOneByteString


    #   _isSpecial is used by marshal.rb . It is not a special selector
    primitive_nobridge '_isSpecial', 'isSpecial'

    def _isBehavior
      false
    end

    #  Private method _each: contains on:do: handler for RubyBreakException ,
    #  all env1 sends of each& are compiled as sends of _each&
    #  Attempts to reimplement _each& will fail with a compile error.
    primitive_nobridge_env '_each&',   '_rubyEach' , ':'

    # _storeRubyVcGlobal is used by methods that need to store into
    #   caller(s) definition(if any) of $~ or $_  .
    #  Receiver is value to be stored.
    #  See smalltalk code in Object for documentation.
    primitive_nobridge '_storeRubyVcGlobal' , '_storeRubyVcGlobal:'
    #  _getRubyVcGlobal returns caller(s) value of $~ or $_ , or nil
    primitive_nobridge '_getRubyVcGlobal' , '_getRubyVcGlobal:'

    # argument to _bindingContext: is number of frames up from sender
    #   of Object.binding from which to create the binding .
    #  Parser has to know about methods which may send _binding_ctx,
    #  to ensure such methods are created with a VariableContext.
    #  see setSendsBinding and the *BindingNode , *EvalNode classes in .mcz
    primitive_nobridge '_binding_ctx' , '_bindingContext:'

    # Special semantics for send of  super  while in bootstrap:
    #   During bootstrap, a send of super passes a block arg only
    #   if no args specified, otherwise only the exact args to super
    #   are passed.
    #   Outside of bootstrap,  super alway passes an explicit or implicit
    #   block argument.    See RubySuperNode in .mcz and Trac 454.

    # End private helper methods

    primitive_nobridge '==', '='
    primitive 'halt'
    primitive 'hash'
    primitive 'object_id', 'asOop'
    primitive '__id__' , 'asOop'

    #  not   is a special selector,
    #   GsComSelectorLeaf>>selector:  translates #not to bytecode Bc_rubyNOT
    # primitive 'not'

    primitive 'nil?' , '_rubyNilQ'

    # rubySend: methods implemented in .mcz
    primitive_nobridge_env 'send',  'rubySend', ':'
    primitive_nobridge_env 'send',  'rubySend', ':with:'
    primitive_nobridge_env 'send',  'rubySend', ':with:with:'
    primitive_nobridge_env 'send',  'rubySend', ':with:with:with:'
    primitive_nobridge_env 'send&', 'rubySend', ':block:'
    primitive_nobridge_env 'send&', 'rubySend', ':with:block:'
    primitive_nobridge_env 'send&', 'rubySend', ':with:with:block:'
    primitive_nobridge_env 'send&', 'rubySend', ':with:with:with:block:'
    primitive_nobridge_env 'send*', 'rubySend', ':withArgs:'
    primitive_env          'send*&' , 'rubySend', ':withArgs:block:'

    #  'send:*&' , '__send__:*&' special cased in  installBridgeMethodsFor ,
    #   to have no bridges.
    #  any other   def send;...  end   gets no bridges  during bootstrap
    #  to allow reimplementation of  send  for methods updating $~ , $_

    #  __send__ defined per MRI, non-overrideable version of send
    #  redefinition of __send__  disallowed by parser after bootstrap finished.
    primitive_nobridge_env '__send__',  'rubySend', ':'
    primitive_nobridge_env '__send__',  'rubySend', ':with:'
    primitive_nobridge_env '__send__',  'rubySend', ':with:with:'
    primitive_nobridge_env '__send__',  'rubySend', ':with:with:with:'
    primitive_nobridge_env '__send__&', 'rubySend', ':block:'
    primitive_nobridge_env '__send__&', 'rubySend', ':with:block:'
    primitive_nobridge_env '__send__&', 'rubySend', ':with:with:block:'
    primitive_nobridge_env '__send__&', 'rubySend', ':with:with:with:block:'
    primitive_nobridge_env '__send__*', 'rubySend', ':withArgs:'
    primitive_env          '__send__*&', 'rubySend', ':withArgs:block:'

    # redefinition of __perform___ disallowed by parser after bootstrap finished.
    # __perform___  requires next to last arg to be a Symbol with proper suffix
    #   for the number of with: keywords;
    #   and last arg is envId
    # it is used by RubyParser
    primitive_nobridge '__perform__se', 'with:with:perform:env:'
    #
    # redefinition of __perform_method disallowed after bootstrap,
    #  it is used by implementation of eval
    primitive_nobridge '__perform_meth', 'performMethod:'

    primitive   '_basic_dup', '_rubyBasicDup'      # use non-singleton class
    primitive   '_basic_clone', '_basicCopy' # use singleton class

    def dup
      res = self._basic_dup
      res.initialize_copy(self)
      res
    end

    def clone
      res = self._basic_clone
      res.initialize_copy(self)
      if self.frozen?
        res.freeze
      end
      res
    end

    primitive 'freeze', 'immediateInvariant'
    primitive 'frozen?', 'isInvariant'

    # _set_nostubbing prevents stubbing ram oops to objectIds in in-memory
    #  instance variables that reference committed objects .  should only
    # be used in limited cases when initializing transient state .
    primitive '_set_nostubbing', '_setNoStubbing'

    # install this prim so  anObj.send(:kind_of?, aCls)   will work
    primitive_nobridge 'kind_of?' , '_rubyKindOf:'

    # install this prim so  anObj.send(:is_a?, aCls)   will work
    # Reimplementation of is_a?  is disallowed, it is compiled direct to a bytecode
    primitive_nobridge 'is_a?' , '_rubyKindOf:'

    primitive_nobridge '_responds_to', '_respondsTo:private:flags:'
       # _responds_to flags bit masks are
       #     environmentId                   0xFF
       #     ruby lookup semantics          0x100
       #     ruby receiver is self         0x1000 (for future use)
       #     cache successes in code_gen  0x10000

    def respond_to?(symbol, include_private)
      _responds_to(symbol, include_private, 0x10101)
    end

    def respond_to?(symbol )
      _responds_to(symbol, false, 0x10101)
    end

    def _splat_lasgn_value
      # runtime support for   x = *y   , invoked from generated code
      a = self
      unless a._isArray
        if a.equal?(nil)
          return a
        end 
        a = a._splat_lasgn_value_coerce
      end 
      if a._isArray
        sz = a.length
        if sz < 2
	  if sz.equal?(0)
	    return nil
	  else
	    return a[0]
	  end
        end
      end
      a
    end

    def _splat_lasgn_value_coerce  
      v = self
      begin
        v = self.to_ary
      rescue
        # ignore if not responding to to_ary
      end
      if v._not_equal?(self)
        unless v._isArray
          raise TypeError, 'arg to splat responded to to_ary but did not return an Array'
        end
      end
      v
    end 

    def _splat_arg_value
      a = self
      unless a._isArray
        a = a._splat_lasgn_value_coerce
        unless a._isArray
          a = [ self ]
        end
      end
      a
    end

    def _splat_return_value_coerce
      # in a separate method from _splat_return_value,
      #  so  _splat_return_value does not have complex ExecBlocks
      v = self
      begin
        v = Type.coerce_to(self, Array, :to_ary)
      rescue TypeError
        begin
          v = Type.coerce_to(self, Array, :to_a)
        rescue TypeError
          # ignore
        end
      end
      v
    end

    def _splat_return_value
      # runtime support for  return *v  , invoked from generated code
      v = self
      unless v._isArray
        v = self._splat_return_value_coerce
      end
      sz = v.length
      if sz < 2
      if sz.equal?(0)
        return nil
      else
        return v[0]
      end
          else
      return v
      end
    end

    def _par_asgn_to_ary
      # runtime support for parallel assignment, invoked from generated code
      if self._isArray
        return self
      elsif self.respond_to?(:to_ary)
        return self.to_ary
      else
        return [ self ]
      end
    end

    primitive 'print_line', 'rubyPrint:'

    # pause is not standard Ruby, for debugging only .
    #  trappable only by an Exception specifying exactly error 6001
    primitive 'pause', 'pause'

    primitive   '_inspect', '_rubyInspect'

    def inspect
      # sender of _inspect must be in env 1
      self._inspect
    end

    #  following 3 prims must also be installed in Behavior
    primitive_nobridge '_instVarAt', 'rubyInstvarAt:'
    primitive_nobridge '_instVarAtPut', 'rubyInstvarAt:put:'
    primitive_nobridge 'instance_variables', 'rubyInstvarNames'

    def instance_variable_get(a_name)
      unless a_name._isStringOrSymbol
        a_name = Type.coerce_to(a_name, String, :to_str)
      end
      _instVarAt(a_name.to_sym)
    end

    def instance_variable_set(a_name, a_val)
      unless a_name._isStringOrSymbol
        a_name = Type.coerce_to(a_name, String, :to_str)
      end
      _instVarAtPut(a_name.to_sym, a_val)
      a_val
    end

    primitive_nobridge 'method', 'rubyMethod:'

    def ===(obj)
        self == obj
    end

    def =~(other)
      false
    end

    # block_given?  is implemented by the ruby parser .
    # implementation in Kernel2.rb handles  sends
    # Attempts to reimplement  block_given? outside of bootstrap code
    #    will fail with a compile error.

    # equal?  is implemented by the ruby parser and optimized to
    #  a special bytecode by the code generator.
    # Attempts to reimplement equal? will fail with a compile error.

    primitive_nobridge 'equal?', '_rubyEqualQ:'    # so send will work

    # _not_equal? is implemented by the ruby parser and optimized to
    #  a special bytecode by the code generator.
    # Attempts to reimplement _not_equal? will fail with a compile error.

    def eql?(other)
      self == other
    end

    def extend(*modules)
      if (modules.length > 0)
        cl = class << self
               self
             end
        modules.each do |aModule|
          cl.include(aModule)
          aModule.extended(self)
        end
      end
      self
    end

    def initialize(*args)
       self
    end
    # implement common variants to avoid runtime cost of bridge methods
    def initialize
      self
    end
    def initialize(a)
      self
    end
    def initialize(a,b)
      self
    end
    def initialize(a,b,c)
      self
    end

    def initialize_copy(other)
      # dup and clone are complete, and C extensions not supported yet,
      #   so do nothing
      self
    end

    def instance_of?(cls)
      # Modified from RUBINIUS
      if self.class.equal?(cls)
        true
      else
        unless cls._isBehavior
          raise TypeError, 'expected a Class or Module'
        end
        false
      end
    end

    primitive_nobridge '_instance_eval', 'rubyEvalString:with:binding:'

    def instance_eval(*args)
      # bridge methods would interfere with VcGlobals logic
      raise ArgumentError, 'wrong number of args'
    end

    def instance_eval(str)
      string = Type.coerce_to(str, String, :to_str)
      ctx = self._binding_ctx(0)
      bnd = Binding.new(ctx, self, nil)
      vcgl = [ self._getRubyVcGlobal(0x20),
               self._getRubyVcGlobal(0x21) ]
      res = _instance_eval(string, vcgl, bnd)
      vcgl[0]._storeRubyVcGlobal(0x20)
      vcgl[1]._storeRubyVcGlobal(0x21)
      res
    end

    def instance_eval(str, file=nil)
      string = Type.coerce_to(str, String, :to_str)
      ctx = self._binding_ctx(0)
      bnd = Binding.new(ctx, self, nil)
      vcgl = [ self._getRubyVcGlobal(0x20),
               self._getRubyVcGlobal(0x21) ]
      res = _instance_eval(string, vcgl, bnd)
      vcgl[0]._storeRubyVcGlobal(0x20)
      vcgl[1]._storeRubyVcGlobal(0x21)
      res
    end

    def instance_eval(str, file=nil, line=nil)
      # TODO: Object#instance_eval: handle file and line params
      string = Type.coerce_to(str, String, :to_str)
      ctx = self._binding_ctx(0)
      bnd = Binding.new(ctx, self, nil)
      vcgl = [ self._getRubyVcGlobal(0x20),
               self._getRubyVcGlobal(0x21) ]
      res = _instance_eval(string, vcgl, bnd)
      vcgl[0]._storeRubyVcGlobal(0x20)
      vcgl[1]._storeRubyVcGlobal(0x21)
      res
    end

    primitive_nobridge_env 'instance_eval&', 'rubyEval', ':'

    # Object should NOT have a to_str.  If to_str is implementd by passing
    # to to_s, then by default all objects can convert to a string!  But we
    # want classes to make an effort in order to convert their objects to
    # strings.
    #
    # def to_str
    #   to_s
    # end

    primitive_nobridge '_ruby_singleton_methods', 'rubySingletonMethods:protection:'

    def singleton_methods(inc_modules = true)
      _ruby_singleton_methods(inc_modules, 0)
    end

    primitive_nobridge '_ruby_methods', 'rubyMethods:'

    # If regular is true, retuns an array of the names of methods publicly
    # accessible in receiver and receiver's ancestors.  Otherwise, returns
    # an array of the names of receiver's singleton methods.
    def methods(regular = true)
      if regular
        _ruby_methods(0) # get public methods
      else
        _ruby_singleton_methods(false, 0)
      end
    end

    def private_methods(unused_boolean=true)
      _ruby_methods(2)
    end

    def protected_methods(unused_boolean=true)
      _ruby_methods(1)
    end

    def singleton_method_added(a_symbol)
     # invoked from code in .mcz when a singleton method is compiled
     # overrides the bootstrap implementation in Object_ruby.gs
     self
    end
    #  cannot make singleton_method_added private yet

    def singleton_method_removed(a_symbol)
     self
    end
    #  cannot make singleton_method_removed private yet

    # TODO   singleton_method_removed

    def to_a
       # remove this method for MRI 1.9 compatibility
       [ self ]
    end

    def to_fmt
      to_s
    end

    def to_s
      self.class.name.to_s
    end

    def _k_to_int
      # sent from C code in primitive 767 for sprintf
      v = nil
      begin
        v = self.to_int
      rescue
        begin
          v = Kernel.Integer(self)
        rescue
          # ignore
        end
      end
      v
    end
  
    ############################################################
    # MagLev API methods on Object
    #
    # These methods are part of MagLev's persistence and debug APIs.
    #
    # TODO:
    #   Should we wrap these in a module and only include them
    #   if requested?
    ############################################################

    # returns true if the receiver existed in GemStone at the time the
    # current transaction began.  Returns false otherwise.
    primitive_nobridge 'committed?', 'isCommitted'

    # Returns an Array of objects in the current session's temporary object
    # memory that reference the receiver.  The search continues until all
    # such objects have been found.  The result may contain both permenent
    # and temporary objects and may vary from run to run.  Does not abort
    # the current transaction.
    primitive_nobridge 'find_references_in_memory', 'findReferencesInMemory'
end


# Sentinal value used to distinguish between nil as a value passed by the
# user and the user not passing anything for a defaulted value.  E.g.,:
#
#   def foo(required_param, optional_param=Undefined)
#     if optional_param.equal?( Undefined )
#       puts "User did not pass a value"
#     else
#       puts "Users passed #{optional_param} (which may be nil)"
#     fi
#   end
#
Undefined = Object.new

