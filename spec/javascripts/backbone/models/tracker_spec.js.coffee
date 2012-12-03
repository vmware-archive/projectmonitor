describe "ProjectMonitor.Models.Tracker", ->
  describe "#normalized_velocities", ->
    it "normalizes correctly", ->
      build = new ProjectMonitor.Models.Tracker(last_ten_velocities: [1,2,3,4,5,6,7,8,9,10])
      expect(build.normalized_velocities()).toEqual([10,20,30,40,50,60,70,80,90,100])
