require 'time'

describe "TimeSpec" do

  it "should build parent ids" do
    time = Time.parse("2015-06-01T13:55:32Z")

    id = SpaceTimeId.new(time.to_i)
    expect(id.ts_step).to eq(3600) # 1 hour
    expect(id.ts_parent.ts_step).to eq(2 * 3600) # 2 hours
    expect(id.ts_parent.ts_parent.ts_step).to eq(2 * 2 * 3600) # 4 hours
    expect(id.ts_parent.ts_parent.ts_parent.ts_step).to eq(2 * 3 * 3600) # 6 hours
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_step).to eq(4 * 2 * 3600) # 8 hours
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_parent.ts_step).to eq(5 * 2 * 3600) # 10 h

    expect(id.ts_id).to eq(Time.parse("2015-06-01T13:00:00Z").to_i) # 1 hour
    expect(id.ts_parent.ts_id).to eq(Time.parse("2015-06-01T12:00:00Z").to_i) # 2 hours
    expect(id.ts_parent.ts_parent.ts_id).to eq(Time.parse("2015-06-01T12:00:00Z").to_i) # 4 hours
    expect(id.ts_parent.ts_parent.ts_parent.ts_id).to eq(Time.parse("2015-06-01T12:00:00Z").to_i)
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_id).to eq(Time.parse("2015-06-01T08:00:00Z").to_i)
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_parent.ts_id).to eq(Time.parse("2015-06-01T02:00:00Z").to_i)
  end

  it "should calculate neighbors" do
  end

  it "should build children ids" do
  end

end
