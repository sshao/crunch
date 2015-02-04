module Crunch
  COLOR_DIFF_THRESHOLD = 13

  class << self
    def crunch(colors)
      crunch_helper(array_to_hash(colors))
    end

    def crunch_helper(colors)
      return colors if colors.nil? || colors.size <= 1

      target_color = colors.keys.first
      grouped, remainder = group_by_color(target_color, colors)

      merge_hashes(crunch_hash(grouped), crunch_helper(remainder))
    end

    def array_to_hash(array)
      return array if array.class == Hash
      array.reduce({}) { |sum, cur| merge_hashes(sum, cur) }
    end

    def group_by_color(target, colors)
      combined = colors.group_by { |color, _| color_diff(target, color) < COLOR_DIFF_THRESHOLD }

      remainder = Hash[combined[false]] unless combined[false].nil?
      grouped = Hash[combined[true]]
      return grouped, remainder
    end

    def crunch_hash(hash)
      { most_frequent_color(hash) => hash.values.inject { |sum, element| sum + element } }
    end

    def most_frequent_color(colors)
      colors.max_by { |_, freq| freq }.first
    end

    def merge_hashes(hash1, hash2)
      return hash1 if hash2.nil?
      return hash2 if hash1.nil?

      hash1.update(hash2) { |_, v1, v2| v1 + v2 }
    end

    def color_diff(color1, color2)
      rgb_color1 = ::Color::RGB.from_html(color1)
      rgb_color2 = ::Color::RGB.from_html(color2)

      # Color::RGB#delta_e94 is an instance method, hence
      # calling it thru rgb_color1
      # defined: http://bit.ly/1puM0uD
      rgb_color1.delta_e94(rgb_color1.to_lab, rgb_color2.to_lab)
    end
  end
end

