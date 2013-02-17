describe "ProjectMonitor.Models.Tracker", ->
  describe "#normalized_velocities", ->
    it "normalizes correctly", ->
      build = new ProjectMonitor.Models.Tracker(last_ten_velocities: [1,2,3,4,5,6,7,8,9,10])
      expect(build.normalized_velocities()).toEqual([100, 90, 80, 70, 60, 50, 40, 30, 20, 10])
