json.(project, :id, :name, :enabled, :code, :location, :tag_list, :created_at, :updated_at)

json.aggregate_project_id project.id
json.aggregate            true
json.status               project.status_in_words