module Caim
  module Cache
    FILE_NAME = "config.yml"
    @@memo = {}
    def self.get key = nil

      if @@memo[key].present?
        return @@memo[key]
      end

      # キャッシュファイルがない時は作成する
      File.open(FILE_NAME, 'w').close if not File.exist? FILE_NAME

      result = YAML.load(File.open(FILE_NAME))
      return nil    if result == false
      return result if key.nil?
      @@memo[key] = result[key]
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
