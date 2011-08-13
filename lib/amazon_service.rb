class AmazonService
  def initialize(access_key_id, secret_access_key)
    @ec2 = AWS::EC2.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
  end

  def start_instance(instance_id)
    puts "Starting service #{instance_id}"
    @ec2.instances[instance_id].start
  end

  def stop_instance(instance_id)
    puts "Stopping service #{instance_id}"
    @ec2.instances[instance_id].stop
  end

  def self.schedule(date)
    puts "Scheduling amazon lobot services at #{date}"
    end_time = date.to_s(:db_time)
    start_time = (date - 7.minutes).to_s(:db_time)
    day = date.to_s(:db_day).downcase

    process_instances(:start, day, end_time, start_time)
    process_instances(:end, day, end_time, start_time)
  end

  private
  def self.process_instances(method, day, end_time, start_time)
    projects = Project.
      where(:"ec2_#{method}_time" => (start_time...end_time)).
      where("projects.ec2_#{day}" => true)
    projects.each do |project|
      service = AmazonService.new(project.ec2_access_key_id, project.ec2_secret_access_key)
      if method == :start
        service.start_instance(project.ec2_instance_id)
      else
        service.stop_instance(project.ec2_instance_id)
      end
    end
  end
end