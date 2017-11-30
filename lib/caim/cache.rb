module Caim
  module Cache
    FILE_NAME = "config.yml"
    def self.get key = nil
      if not File.exist? FILE_NAME
        File.open(FILE_NAME, 'w').close
      end
      yaml = YAML.load(File.open(FILE_NAME))
      return nil  if yaml == false
      return yaml if key.nil?
      yaml[key]
    end

    def self.save save_item
      now = self.get
      new_item = now.blank? ? save_item : now.merge(save_item)
      file = File.open(FILE_NAME, 'w')
      YAML.dump(new_item, file)
      file.close
      self.get
    end
  end
end
