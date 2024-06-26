#!/usr/bin/env ruby

stack = []

# Read from standard input
ARGF.each_line do |line|
  match = line =~ /\S/
  next if match.nil?

  # Calculate depth by the number of leading spaces (each indent is 2 spaces in the example)
  depth = match / 2
  method_info = line.strip

  if method_info.include?('<')
    method, timing = method_info.split('<')
    timing = (timing.to_f * 1000000).to_i  # Convert seconds to microseconds
    method = [method.strip, timing]
  else
    method = [method_info.strip]
  end

  if method.size == 2 && stack.length == depth # on the same depth
    puts (stack + ["#{method[0]} #{method[1]}"]).join(';')
    next
  end

  if method.size == 1 # start of new block
    stack.push(method)
    next
  end

  if stack.length > depth # go to lesser level
    stack.pop
  end
end

### INPUT
# IO.select <0.000044>
# IO.select <0.000055>
#
# Puma::Client#eagerly_finish
#   IO.select <0.000010>
#   Puma::Client#try_to_finish
#     BasicSocket#read_nonblock
#       BasicSocket#__read_nonblock <0.000018>
#     BasicSocket#read_nonblock <0.000029>
#   Puma::Client#try_to_finish <0.000153>
# Puma::Client#eagerly_finish <0.000179>

### OUTPUT
# IO.select 44
# IO.select 55
# Puma::Client#eagerly_finish;IO.select 10
# Puma::Client#eagerly_finish;Puma::Client#try_to_finish;BasicSocket#read_nonblock;BasicSocket#__read_nonblock 18


### INPUT of rbtrace --slow=100
# IO.select <0.824050>
#           Kernel#sleep <1.000291>
#           Kernel#sleep <1.000246>
#           Kernel#sleep <0.864987>
#           Kernel#sleep <0.802881>
#         Rack::Proxy#call <5.058375>
#       Rails::Engine#call <5.058540>
#     Puma::Configuration::ConfigMiddleware#call <5.058627>
#   Puma::Server#handle_request <5.079132>
# Puma::Server#process_client <5.079287>

### OUTPUT
# ?



# TODO: But we could make even better format?
# Because pauses still don't count
# eagerly_finish took 179, not 10 + 18

## TODO: rbtrace with --slow
