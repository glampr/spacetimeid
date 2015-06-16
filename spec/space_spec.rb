describe "SpaceSpec" do

  it "should build parent ids" do
    id = SpaceTimeId.new([1.468, -3.028])
    expect(id.id).to eq("1.46_-3.03")
    expect(id.xy_parent.id).to eq("1.45_-3.05")
    expect(id.xy_parent.xy_parent.id).to eq("1.25_-3.25")
  end

  it "should calculate neighbors" do
    id = SpaceTimeId.new([10.235, -23.345])
    expect(id.id).to eq("10.23_-23.35")

    expect(id.next_x).to eq(10.24)
    expect(id.next_x(10)).to eq(10.33)
    expect(id.next_y).to eq(-23.34)
    expect(id.next_y(-10)).to eq(-23.45)

    expect(id.xy_neighbors.map(&:id)).to match_array([
      "10.22_-23.34", "10.23_-23.34", "10.24_-23.34",
      "10.22_-23.35",                 "10.24_-23.35",
      "10.22_-23.36", "10.23_-23.36", "10.24_-23.36",
    ])
  end

  it "should build children ids" do
    id = SpaceTimeId.new([1.468, -3.028])
    expect{id.children}.to raise_error(StandardError)

    parent = id.xy_parent
    expect(parent.id).to eq("1.45_-3.05")

    children = parent.xy_children
    expect(children).to include(id)
    expect(children.map(&:level)).to all(eq(0))
    expect(children.map(&:id)).to match_array([
      "1.45_-3.05", "1.46_-3.05", "1.47_-3.05", "1.48_-3.05", "1.49_-3.05",
      "1.45_-3.04", "1.46_-3.04", "1.47_-3.04", "1.48_-3.04", "1.49_-3.04",
      "1.45_-3.03", "1.46_-3.03", "1.47_-3.03", "1.48_-3.03", "1.49_-3.03",
      "1.45_-3.02", "1.46_-3.02", "1.47_-3.02", "1.48_-3.02", "1.49_-3.02",
      "1.45_-3.01", "1.46_-3.01", "1.47_-3.01", "1.48_-3.01", "1.49_-3.01",
    ])

    grandparent = id.xy_parent.xy_parent
    family = grandparent.xy_descendants
    expect(grandparent.id).to eq("1.25_-3.25")
    expect(family.size).to eq(625+25)
  end

end
