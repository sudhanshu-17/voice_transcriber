class CreateTranscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :transcriptions do |t|
      t.text :content
      t.text :summary
      t.string :status, default: 'processing'
      t.string :session_id, null: false
      t.timestamps
    end

    add_index :transcriptions, :session_id
    add_index :transcriptions, :status
  end
end
