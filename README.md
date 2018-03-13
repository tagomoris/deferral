# Deferral - introduce golang style "defer" in Ruby

```ruby
# gem install deferral

require "deferral/toplevel"
using Deferral::TopLevel
# it makes "defer" without module name available everywhere in this file

def my_method_name
  # ...
  file = File.open("my_file", "r")
  defer { file.close }

  file.write "data..."
  # ...
end # `file.close` is called at the end of method (even when exception thrown)

# or end of blocks
def my_method_name(list)
  # ...
  list.each do |item|
    file = File.open(item, "r")
    defer { file.close }

    file.write "data..."
    # ...
  end # `file.close` is called at the end of block
end

# "deferral" imports `Deferral.defer`, not to inject top-level methods widely.
require "deferral"

# or enable everywhere! (DANGER!)
require "deferral/kernel_ext"
```

This gem provides a feature to release resources safely, using golang style `defer` method.

`Deferral.defer` method does:

* accept a block argument to execute at the end of caller scope
* execute specified blocks in reverse order when getting out from specified scope

Resource release blocks are called even when any exception occurs.

See also [with_resources gem](https://github.com/tagomoris/with_resources) for try-with-resources style resource allocator.

### Disclosure

This library is a kind of PoC to introduce safe resource allocation in Ruby world. Take care about using this library in your production environment.

This library uses/enables TracePoint, and it may collapse optimizations of your Ruby runtime.

## API

* `Deferral.defer(&block)`

This method registers a block to be called at the end of caller scope (end of method or block). Registered blocks will be called in reverse order (LIFO: last-in, first-out) when this method is called twice or more in a scope.

### Introduce `defer` to top-level namespace

Top-level `defer` is available via 2 different ways. One is using Refinements, another is modifying `Kernel` in open-class way.

```ruby
require "deferral/toplevel"
using Deferral::TopLevel

def my_method
  f = AnyResource.new
  defer { f.close }
  # ...
end
```

Refinements is a feature of Ruby to apply Module modification in just a file (by `using` statement).
`using Deferral::TopLevel` introduces top level `defer` in safer way than modifying `Kernel`.

```ruby
require "deferral/kernel_ext"

# now, "defer" is available everywhere...
```

Requiring `deferral/kernel_ext` modifies `Kernel` module globally to add `deferral`. It's not recommended in most cases.

* * * * *

## Authors

* Satoshi Tagomori <tagomoris@gmail.com>

## License

MIT (See License.txt)
