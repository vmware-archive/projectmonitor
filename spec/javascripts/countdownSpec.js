describe("countdown timer", function () {
  beforeEach(function() {
    setFixtures("<span id='time_left'>10</span>");
  });
  it("should count down to 0 and then display ASAP", function() {

    jasmine.Clock.useMock();

    Application.startTimer();

    expect(jQuery('#time_left')).toHaveText(10);

    jasmine.Clock.tick(12000);
    expect(jQuery('#time_left')).toHaveText('ASAP');
  });
});