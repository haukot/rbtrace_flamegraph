# rbtrace_flamegraph

# Usage

Store your logs
```
rbtrace -p 15838 --firehose > trace.log
```

Get stackcollapse output
```
cat trace.log | ./rbtrace_stackcollapse.rb > rbtrace_stacks
```

And then generate speedscope output and use https://www.speedscope.app/
```
ruby convert_to_speedscoper.rb rbtrace_stacks_all rbtrace.speedscope.json
```

Or render flamegraph to svg using https://github.com/brendangregg/FlameGraph/
```
flamegraph.pl --color=io --width=1800 --title="Rbtrace" ~/programming/projects/slurm/slurm/rbtrace_stacks_all > rbtrace.svg
```
