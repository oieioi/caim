module ZaimCli
  module Cache
    FILE_NAME = "config.yml"
    def self.get key = nil
      y = YAML.load(File.open(FILE_NAME))
      return y if key.nil?
      y[key]

    end

    def self.save save_item
      now = self.get
      new_item = now.merge(save_item)
      file = File.open(FILE_NAME, 'w')
      YAML.dump(new_item, file)
      file.close
      self.get
    end
  end
end
