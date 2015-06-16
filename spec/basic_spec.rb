require 'time'

describe "BasicSpec" do

  it "should build a simple id" do
    time = Time.parse("2015-06-01T00:05:32Z")

    id = SpaceTimeId.new(time.to_i)
    expect(id.id).to eq("1433116800")

    id = SpaceTimeId.new([1.3, -3.048])
    expect(id.id).to eq("1.30_-3.05") # does not round, floor but negative
    expect(id).to eq(SpaceTimeId.new(1.3, -3.048))

    id = SpaceTimeId.new(time.to_i, [1.3, -3.048])
    expect(id.id).to eq("1433116800_1.30_-3.05")
    expect(id).to eq(SpaceTimeId.new(time.to_i, 1.3, -3.048))

    id = SpaceTimeId.new("1433117132_1.3_-3.048")
    expect(id.id).to eq("1433116800_1.30_-3.05")
  end

end
