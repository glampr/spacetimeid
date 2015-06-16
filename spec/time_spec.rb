require 'time'

describe "TimeSpec" do

  it "should build parent ids" do
    time = Time.parse("2015-06-01T01:25:32Z")

    id = SpaceTimeId.new(time.to_i)
    expect(id.ts_step).to eq(600)
    expect(id.ts_parent.ts_step).to eq(1800)
    expect(id.ts_parent.ts_parent.ts_step).to eq(3600)
    expect(id.ts_parent.ts_parent.ts_parent.ts_step).to eq(3*3600)
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_step).to eq(6*3600)
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_parent.ts_step).to eq(12*3600)
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_parent.ts_parent.ts_step).to eq(24*3600)

    expect(id.id).to eq("1433121600")
    expect(id.ts_parent.id).to eq("1433120400")
    expect(id.ts_parent.ts_parent.id).to eq("1433120400")
    expect(id.ts_parent.ts_parent.ts_parent.id).to eq("1433116800")
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.id).to eq("1433116800")
    expect(id.ts_parent.ts_parent.ts_parent.ts_parent.ts_parent.id).to eq("1433116800")
  end

  it "should calculate neighbors" do
  end

  it "should build children ids" do
  end

end
