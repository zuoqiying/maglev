module Kernel
  # file Kernel2.rb  , parts of kernel that must be deferred to later
  #  in the bootstrap

  def binding
    # usually the block argument is synthesized by the parser.
    # this case is used to create the top-level binding. 
    Binding.new( self._binding_ctx(0), self, nil )
  end

  def binding(&blk)
    Binding.new( self._binding_ctx(0), self , blk)
  end

  def lambda(&blk)
    Proc.new_lambda(&blk)
  end

  def proc(&blk)
    Proc.new(&blk)
  end

  def rand(n=nil)
    if n
      RandomInstance.next(n) - 1
    else
      RandomInstance.next
    end
  end

end
