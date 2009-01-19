module Kernel

  # Print messages for stubbed methods
  @@gs_WARNSTUB = false
  def _stub_warn(msg)
    puts "== WARN: STUB: MNI: #{msg}" if @@gs_WARNSTUB
  end

#  RUBY.class.primitive '_require', 'requireFileNamed:qualified:'
  def require(name)
    if $LOADED_FEATURES.include? name
      false
    else
      Kernel.unified_load(name)
    end
  end

  def load(name)
    Kernel.unified_load(name)
  end

  # TODO: Kernel#unified_load: Currently, we only expand ~/..., not ~user/...
  #
  # If the path given starts with ./, ../, ~/ or /, it is treated
  # as a "qualified" file and will be loaded directly (after path
  # expansion) instead of matching against $LOAD_PATH. The relative
  # paths use Dir.pwd.

  def self.unified_load(name)
    qualified = false
    if name =~ %r{\A(?:(\.\.?)|~)?/}
#      puts "===== #{name} is qualified"
      # A qualified name.
      qname = name.gsub(/^~/, ENV['HOME'])
      qualified = true
    else
      qname = name
    end
#    RUBY.require(name, qualified)
    RUBY.require(qname)
    $LOADED_FEATURES << name unless $LOADED_FEATURES.include? name
    true
  end

  def at_exit
    _stub_warn("Kernel#at_exit")
  end

  # following methods are just those needed to get some benchmarks and
  # specs running .

  # Kernel#autoload: STUB: This stubbed version just calls +require
  # file_name+ rather than defering the require.
  #
  # See ruby-core:20222 for a discussion on whether to use Kernel#require or some
  # other private implementation for autoload.
  def autoload(name, file_name)
    _stub_warn("Kernel#autoload:  does an immediate require (does not defer)")
    require file_name
    nil
  end

  # Kernel#autoload?: STUB: Always returns nil.
  def autoload?(name)
    _stub_warn('Kernel#autoload?: always returns nil')
    nil
  end

  primitive_nobridge '_last_dnu_protection', '_lastDnuProtection'

  def method_missing(method_id, *args)
    prot = _last_dnu_protection()
    if (prot.equal?(0)) 
      raise NoMethodError, "Undefined method `#{method_id}' for #{self}  "
    elsif (prot.equal?(1))
      raise NoMethodError, "protected method `#{method_id}' called for  #{self}"
    else
      raise NoMethodError, "private method `#{method_id}' called for  #{self}"
    end
  end

  def caller(skip=0, limit=1000)
    # returns an Array of Strings, each element describes a stack frame
    unless skip._isFixnum
      raise ArgumentError
    end
    res = Thread._backtrace(false, limit)
    if (skip > 0)
      res = res[skip, res.length]
    end
    res
  end

  # def catch(aSymbol, &aBlock); end
  primitive_nobridge 'catch&' , 'catch:do:'

  primitive_nobridge '_eval', '_eval:with:'

  def eval(str)
    vcgl = [ self._getRubyVcGlobal(0x20) ,
             self._getRubyVcGlobal(0x21) ]
    res = _eval(str, vcgl)
    vcgl[0]._storeRubyVcGlobal(0x20)
    vcgl[1]._storeRubyVcGlobal(0x21)
    res
  end

  def exit(arg=1)
    status = '9'
    if (arg.equal?(true))
      status = '0'
    elsif (arg._isInteger)
      status = arg.to_s
    end
    raise SystemExit , status
  end

  primitive 'format*', 'sprintf:with:'

  def loop
    raise LocalJumpError, "no block given" unless block_given?

    while true
      yield
    end
  end

  def open(fName)
    File.open(fName)
  end

  def open(fName, mode)
    File.open(fName, mode)
  end

  def p(obj)
    f = STDOUT
    f.write(obj.inspect)
    f.write("\n")   # TODO observe record sep global
    nil
  end

  def print(*args)
    STDOUT.print(*args)
    nil
  end

  def printf(a, b, c, *d)
    if (a.kind_of?(IO))
      if (d._isArray)
        args = [ c ]
        args.concat(*d)
      else
        args = [ c , d ]
      end
      a.printf(b, *args)
    else
      if (d._isArray)
        args = [ b, c ]
        args.concat(*d)
      else
        args = [ b, c , d ]
      end
      STDOUT.printf(a, *args)
    end
  end

  def printf(a, b, c)
    if (a.kind_of?(IO))
      a.printf(b, c)
    else
      STDOUT.printf(a, b, c)
    end
  end

  def printf(a, b)
    if (a.kind_of?(IO))
      a.printf(b)
    else
      STDOUT.printf(a, b)
    end
  end

  def printf(a)
    STDOUT.printf(a)
  end

  # def proc ...  in Kernel2.rb

  def puts(*args)
    if STDOUT.nil?
      raise "STDOUT is nil in Kernel.puts!"
    else
      STDOUT.puts(*args)
    end
    nil
  end

  def putc(arg)
    STDOUT.putc(arg)
    arg
  end

  # def rand #  implemented in Kernel2.rb

  def raise(ex_class, message)
    ex = ex_class.exception
    ex.signal(message)
  end

  def raise(ex_class, message, *args)
    # args is callback info not yet implemented
    raise(ex_class, message)
  end

  def raise(msg)
    if msg._isString
      raise(RuntimeError, msg)
    else
      # msg should be a subclass of Exception or
      #  an object that returns a new exception
      ex = msg.exception
      ex.signal
    end
  end

  def _reraise(ex)
    ex._reraise
  end

  def raise
    #  if $! is valid in the caller, the parser will
    #   translate raise to  _resignal
    RuntimeError.signal
  end

  primitive 'sprintf*', 'sprintf:with:'

  primitive_nobridge '_system', '_system:'

  def system(command, *args)
    cmd = command
    n = 0
    sz = args.length
    while n < sz
      if (n < sz - 1)
        cmd << ' '
      end
      cmd << args[n].to_s
      n = n + 1
    end
    resultStr = Kernel._system(cmd)
    if (resultStr)
      puts resultStr
      return true
    end
    return false
  end

  def trap(signal, proc)
    _stub_warn("Kernel#trap(signal, proc)")
  end

  def trap(signal, &block)
    _stub_warn("Kernel#trap(signal, &block)")
  end

  # def throw(aSymbol); end
  primitive_nobridge 'throw' , 'throw:'

  # def throw(aSymbol, aValue); end
  primitive_nobridge 'throw' , 'throw:with:'

  # This is a hook into the mspec framework so that the --spec-debug action
  # can call us.  E.g., to debug a failing spec, do:
  #
  #   spec/mspec/bin/mspec -T -d --spec-debug -K fails spec/rubyspec/1.8/core/string/append_spec.rb
  def debugger
    nil.pause
  end
end
