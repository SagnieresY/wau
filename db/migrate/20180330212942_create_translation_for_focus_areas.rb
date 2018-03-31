class CreateTranslationForFocusAreas < ActiveRecord::Migration[5.1]
	def self.up
	    FocusArea.create_translation_table!({
	      :name => :string,
	    }, {
	      :migrate_data => true,
	      :remove_source_columns => true
	    })
  	end

	def self.down
		FocusArea.drop_translation_table! :migrate_data => true
	end
end
