Kumquat::Application.kumquat_config =
    YAML.load_file(File.join(Rails.root, 'config', 'kumquat.yml'))[Rails.env]
