require 'json'

def convert_to_speedscope(input_file)
  frames = []
  frame_map = {}
  samples = []
  weights = []
  current_time = 0

  File.readlines(input_file).each do |line|
    parts = line.strip.split
    stack_trace = parts[0]
    sample_count = parts[1].to_i

    stack_frames = stack_trace.split(';')
    sample_indices = []

    stack_frames.each do |frame|
      unless frame_map.key?(frame)
        frame_map[frame] = frames.length
        frames << { "name" => frame }
      end
      sample_indices << frame_map[frame]
    end

    samples << sample_indices
    weights << sample_count
    current_time += sample_count
  end

  # Create the Speedscope JSON structure
  speedscope_profile = {
    "$schema" => "https://www.speedscope.app/file-format-schema.json",
    "profiles" => [
      {
        "type" => "sampled",
        "name" => "Profile",
        "unit" => "microseconds",
        "startValue" => 0,
        "endValue" => current_time,
        "samples" => samples,
        "weights" => weights,
      }
    ],
    "shared" => {
      "frames" => frames
    },
    "exporter" => "Custom stackcollapse to Speedscope converter"
  }

  speedscope_profile
end

if ARGV.length != 2
  puts "Usage: ruby convert_to_speedscope.rb input.txt output.json"
else
  input_file = ARGV[0]
  output_file = ARGV[1]

  result = convert_to_speedscope(input_file)

  File.open(output_file, "w") do |file|
    file.write(JSON.pretty_generate(result))
  end

  puts "Conversion complete. Output saved to #{output_file}"
end
