json.array! @projects do |project|
  json.partial! project.to_partial_path, project: project
end