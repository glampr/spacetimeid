class SpaceTimeId

  DEFAULTS = {
    xy_base_step: 0.01, # 0.01 degrees
    xy_expansion: 5,    # expands into a 5x5 grid recursively
    ts_base_step: 600,  # 10 minutes
    ts_expansion: [1, 3, 2, 3, 2], # expands 3 times each interval, then 2, then 3....
    decimals: 2
  }

  attr_accessor :ts_sec
  attr_accessor :x
  attr_accessor :y
  attr_accessor :options
  attr_accessor :interval
  attr_accessor :level

  def initialize(*args)
    self.options = DEFAULTS.merge(args.extract_options!)
    self.interval = options.delete(:interval) || 0
    self.level = options.delete(:level) || 0
    options[:ts_expansion] = Array(options[:ts_expansion])
    if args.length == 1 && args.first.is_a?(String)
      initialize(*args.first.split("_").map(&:to_f), original_options)
    elsif args.length == 1 && args.first.is_a?(Array) && args.first.length == 2
      initialize(*(args.first), original_options)
    elsif args.all? { |arg| arg.is_a?(Fixnum) || arg.is_a?(Float) }
      case args.length
      when 1
        self.ts_sec = args.first
        self.ts_sec = ts_id.to_i
      when 2
        self.x, self.y = args
        self.x, self.y = xy_id_2d
      when 3
        self.ts_sec, self.x, self.y = args
        self.x, self.y = xy_id_2d
        self.ts_sec = ts_id.to_i
      else
        raise "Invalid initialize arguments! (#{args.inspect})"
      end
    elsif args.length == 2 &&
        (args.first.is_a?(Fixnum) || args.first.is_a?(Float)) && args.last.is_a?(Array)
      ts = args.first
      x, y = args.last
      initialize(ts, x, y, original_options)
    else
      raise "Invalid initialize arguments! (#{args.inspect})"
    end
  end

  def id
    [ts_id, xy_id_str].compact.join("_")
  end

  def to_s
    id
  end

  def inspect
    "<SpaceTimeId:#{id} #{original_options.inspect}>"
  end

  def to_html
    html = "id: #{id}<br/>"
    if ts?
      html << "interval: #{inteval}<br/>"
      html << "time_base_step: #{time_base_step}<br/>"
      html << "time_expansion: #{time_expansion}<br/>"
    end
    if xy?
      html << "level: #{level}<br/>"
      html << "xy_base_step: #{xy_base_step}<br/>"
      html << "xy_expansion: #{xy_expansion}<br/>"
    end
    html
  end

  def ==(other)
    other.nil? || !other.respond_to?(:id) ? false : id == other.id
  end

  def eql?(other)
    other.is_a?(SpaceTimeId) && self == other
  end

  def hash
    [id, interval, level].hash
  end

  def dup(new_id = id, options = self.options)
    SpaceTimeId.new(new_id, original_options.merge(options))
  end

  def dec
    options[:decimals]
  end

  def original_options
    {level: level, interval: interval}.merge(options)
  end

  # # # # # # # # # # # # T I M E # # # # # # # # # # # # # # # # # # # # # # #

  def ts?
    !ts_sec.nil?
  end

  def ts
    Time.at(ts_sec) if ts_sec
  end

  def ts_ms
    ts_sec * 1000 if ts_sec
  end

  def ts_id
    digitize(ts_sec, ts_step).to_i if ts_sec
  end

  def ts_step
    @ts_step ||= ts_step_aux(interval)
  end

  def ts_step_aux(interval)
    ts_base_step * ts_expansion
  end

  def ts_base_step
    options[:ts_base_step]
  end

  def ts_expansion
    ts_expansion_aux
    options[:ts_expansion][0..interval].reduce(:*)
  end

  def ts_expansion_aux
    if interval >= options[:ts_expansion].length
      padd = [options[:ts_expansion].last] * (options[:ts_expansion].length - interval + 1)
      options[:ts_expansion] += padd
    end
  end

  # # # # # # # # # # # # # T I M E   R E L A T I O N S # # # # # # # # # # # #

  def next_ts(i = 1)
    @_next_ts ||= {}
    @_next_ts[i] ||= digitize(ts_id + ts_step * i + ts_step / 2.0, ts_step) if ts?
  end

  def ts_neighbors
    @ts_neighbors ||= begin
      prevt = dup(next_ts(-1))
      nextt = dup(next_ts)
      @ts_neighbors = [prevt, nextt]
    end if ts?
  end

  def ts_parent
    dup(id, interval: interval + 1) if ts?
  end

  # # # # # # # # # # # # S P A C E # # # # # # # # # # # # # # # # # # # # # #

  def xy?
    !xy.empty?
  end

  def xy
    [x, y].compact
  end

  def xy_id_2d
    xy.map { |c| digitize(c, xy_step).round(dec) } if xy?
  end

  def xy_id_str
    xy.map { |c| digitize_str(c, xy_step, dec) } .join("_") if xy?
  end

  def xy_id_2d_center
    xy_id_2d.map { |c| (c + (xy_step / 2.0)).round(dec * 2) } if xy?
  end

  def xy_id_str_center
    xy_id_2d_center.map { |c| digitize_str(c, (xy_step / 2.0), dec * 2) } .join("_") if xy?
  end

  def xy_step
    (xy_expansion ** level) * xy_base_step
  end

  def xy_base_step
    options[:xy_base_step]
  end

  def xy_expansion
    options[:xy_expansion]
  end

  # # # # # # # # # # # # S P A C E   R E L A T I O N S # # # # # # # # # # # #

  def next_x(i = 1)
    @_next_x ||= {}
    @_next_x[i] ||= digitize(x + xy_step * i + xy_step / 2.0, xy_step) if xy?
  end

  def next_y(i = 1)
    @_next_y ||= {}
    @_next_y[i] ||= digitize(y + xy_step * i + xy_step / 2.0, xy_step) if xy?
  end

  def xy_neighbors
    @xy_neighbors ||= begin
      topLeft      = dup([next_x(-1), next_y(1) ])
      top          = dup([x         , next_y(1) ])
      topRight     = dup([next_x(1) , next_y(1) ])
      right        = dup([next_x(1) , y         ])
      bottomRight  = dup([next_x(1) , next_y(-1)])
      bottom       = dup([x         , next_y(-1)])
      bottomLeft   = dup([next_x(-1), next_y(-1)])
      left         = dup([next_x(-1), y         ])
      @xy_neighbors = [topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left]
    end if xy?
  end

  def xy_parent
    dup(id, level: level + 1) if xy?
  end

  def xy_children
    raise "No children for level zero!" if level == 0
    @xy_children ||= begin
      bottom_left = dup(id, level: level - 1)
      @xy_children = []
      (0...xy_expansion).each do |h|
        (0...xy_expansion).each do |v|
          @xy_children << bottom_left.dup([bottom_left.next_x(h), bottom_left.next_y(v)])
        end
      end
      @xy_children
    end if xy?
  end

  def xy_descendants
    xy_children + (level == 1 ? [] : xy_children.map(&:xy_descendants).flatten) if xy?
  end

  def xy_siblings
    xy_parent.xy_children if xy?
  end

  def xy_box
    [xy, [next_x, next_y]] if xy?
  end

  def xy_four_corners
    [xy, [next_x, y], [next_x, next_y], [x, next_y]] if xy?
  end

  def xy_boundary
    xy_four_corners << xy if xy?
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  private

  def digitize n, step
    # JS method to avoid floating point rounding errors: 85.000000000000001
    # Math.floor((c + @baseStep / 1000) / @baseStep) / (1 / @baseStep)
    step = step.to_f
    ((n + step / 1000) / step).floor / (1 / step)
  end

  def digitize_str n, step, dec = 2
    n = digitize n, step
    "%.#{dec}f" % n
  end

end
